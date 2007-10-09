From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 13:53:40 -0700
Message-ID: <20071009135340.33e5922c@freepuppy.rosehill>
References: <470AD5D7.1070000@garzik.org>
	<20071008.184126.124062865.davem@davemloft.net>
	<p73k5pw44ew.fsf@bingen.suse.de>
	<20071009.134331.35664207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, jeff@garzik.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, andi@firstfloor.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, randy.dunlap@oracle.com, jagana@us.ibm.com,
	kaber@trash.net, mchan@broadcom.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009.134331.35664207.davem@davemloft.net>
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

On Tue, 09 Oct 2007 13:43:31 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andi Kleen <andi@firstfloor.org>
> Date: 09 Oct 2007 18:51:51 +0200
> 
> > Hopefully that new qdisc will just use the TX rings of the hardware
> > directly. They are typically large enough these days. That might avoid
> > some locking in this critical path.
> 
> Indeed, I also realized last night that for the default qdiscs
> we do a lot of stupid useless work.  If the queue is a FIFO
> and the device can take packets, we should send it directly
> and not stick it into the qdisc at all.
> 
> > If the data is just passed on to the hardware queue, why is any 
> > locking needed at all? (except for the driver locking of course)
> 
> Absolutely.
> 
> Our packet scheduler subsystem is great, but by default it should just
> get out of the way.

I was thinking why not have a default transmit queue len of 0 like
the virtual devices.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
