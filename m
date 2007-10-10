From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 02:37:16 +0200
Message-ID: <20071010003716.GB552@one.firstfloor.org>
References: <20071009135340.33e5922c@freepuppy.rosehill>
	<20071009.142235.74385364.davem@davemloft.net>
	<1191967006.5324.14.camel@localhost>
	<20071009.170435.43504422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, gaagaan@gmail.com, andi@firstfloor.org,
	general@lists.openfabrics.org, jagana@us.ibm.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	kaber@trash.net, mchan@broadcom.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20071009.170435.43504422.davem@davemloft.net>
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

On Tue, Oct 09, 2007 at 05:04:35PM -0700, David Miller wrote:
> We have to keep in mind, however, that the sw queue right now is 1000
> packets.  I heavily discourage any driver author to try and use any
> single TX queue of that size.  

Why would you discourage them? 

If 1000 is ok for a software queue why would it not be ok
for a hardware queue?

> Which means that just dropping on back
> pressure might not work so well.
> 
> Or it might be perfect and signal TCP to backoff, who knows! :-)

1000 packets is a lot. I don't have hard data, but gut feeling 
is less would also do.

And if the hw queues are not enough a better scheme might be to
just manage this in the sockets in sendmsg. e.g. provide a wait queue that
drivers can wake up and let them block on more queue.

> The idea is that the network stack, as in the pure hw queue scheme,
> unconditionally always submits new packets to the driver.  Therefore
> even if the hw TX queue is full, the driver can still queue to an
> internal sw queue with some limit (say 1000 for ethernet, as is used
> now).
>
> 
> When the hw TX queue gains space, the driver self-batches packets
> from the sw queue to the hw queue.

I don't really see the advantage over the qdisc in that scheme.
It's certainly not simpler and probably more code and would likely
also not require less locks (e.g. a currently lockless driver
would need a new lock for its sw queue). Also it is unclear to me
it would be really any faster.

-Andi
