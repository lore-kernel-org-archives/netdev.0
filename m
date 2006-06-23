From: "Steve Wise" <swise@opengridcomputing.com>
Subject: Re: [PATCH v3 1/7] AMSO1100 Low Level Driver.
Date: Fri, 23 Jun 2006 08:56:45 -0500
Message-ID: <1151071005.7808.39.camel@stevo-desktop>
References: <20060620203050.31536.5341.stgit@stevo-desktop>
 <20060620203055.31536.15131.stgit@stevo-desktop>
 <1150836226.2891.231.camel@laptopd505.fenrus.org>
 <1151070290.7808.33.camel@stevo-desktop>
 <1151070532.3204.10.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "Arjan van de Ven" <arjan@infradead.org>
In-Reply-To: <1151070532.3204.10.camel@laptopd505.fenrus.org>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-23 at 15:48 +0200, Arjan van de Ven wrote:
> > > > +	/* Tell HW to xmit */
> > > > +	__raw_writeq(cpu_to_be64(mapaddr), elem->hw_desc + C2_TXP_ADDR);
> > > > +	__raw_writew(cpu_to_be16(maplen), elem->hw_desc + C2_TXP_LEN);
> > > > +	__raw_writew(cpu_to_be16(TXP_HTXD_READY), elem->hw_desc + C2_TXP_FLAGS);
> > > 
> > > or here
> > > 
> > 
> > No need here.  This logic submits the packet for transmission.  We don't
> > assume it is transmitted until we (after a completion interrupt usually)
> > read back the HTXD entry and see the TXP_HTXD_DONE bit set (see
> > c2_tx_interrupt()). 
> 
> ... but will that interrupt happen at all if these 3 writes never hit
> the hardware?
> 

I thought the posted write WILL eventually get to adapter memory.  Not
stall forever cached in a bridge.  I'm wrong?

My point is for a given HTXD entry, we write it to post a packet for
transmission, then only free the packet memory and reuse this entry
_after_ reading the HTXD and seeing the DONE bit set.  So I still don't
see a problem.  But I've been wrong before ;-)

Steve.
