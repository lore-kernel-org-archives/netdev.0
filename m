From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 14:26:26 -0700 (PDT)
Message-ID: <20071008.142626.26988698.davem@davemloft.net>
References: <1191868010.4335.33.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>
	<1191876530.4373.58.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, randy.dunlap@oracle.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, jeff@garzik.org,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1191876530.4373.58.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 08 Oct 2007 16:48:50 -0400

> On Mon, 2007-08-10 at 12:46 -0700, Waskiewicz Jr, Peter P wrote:
> 
> > 	I still have concerns how this will work with Tx multiqueue.
> > The way the batching code looks right now, you will probably send a
> > batch of skb's from multiple bands from PRIO or RR to the driver.  For
> > non-Tx multiqueue drivers, this is fine.  For Tx multiqueue drivers,
> > this isn't fine, since the Tx ring is selected by the value of
> > skb->queue_mapping (set by the qdisc on {prio|rr}_classify()).  If the
> > whole batch comes in with different queue_mappings, this could prove to
> > be an interesting issue.
> 
> true, that needs some resolution. Heres a hand-waving thought:
> Assuming all packets of a specific map end up in the same qdiscn queue,
> it seems feasible to ask the qdisc scheduler to give us enough packages
> (ive seen people use that terms to refer to packets) for each hardware
> ring's available space. With the patches i posted, i do that via
> dev->xmit_win that assumes only one view of the driver; essentially a
> single ring.  
> If that is doable, then it is up to the driver to say
> "i have space for 5 in ring[0], 10 in ring[1] 0 in ring[2]" based on
> what scheduling scheme the driver implements - the dev->blist can stay
> the same. Its a handwave, so there may be issues there and there could
> be better ways to handle this.

Add xmit_win to struct net_device_subqueue, problem solved.
