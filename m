From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 09:31:53 -0500
Message-ID: <1108996313.1090.178.camel@jzny.localdomain>
References: <20050220230713.GA62354@muc.de>
	 <200502210332.j1L3WkDD014744@guinness.s2io.com>
	 <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch>
	 <1108994621.1089.158.camel@jzny.localdomain>
	 <20050221141714.GV31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050221141714.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I have done the experiments and even posted the patches on netdev last
year to batch on enqueue. 
Despite Andis assertion that theres value in amortizing the locks, the
benefits are highly missing on a generic level unfortunately.
Locking overhead is like the 50th item on things you have to worry about
- so i wouldnt even start worrying about this. 
Infact performance goes down when you batch in some cases depending on
the hardware used. My investigation shows that if you have a fast CPU
and a fast bus, theres always only one packet in flight within the
stack. Batching by definition requires more than one packet.

cheers,
jamal

On Mon, 2005-02-21 at 09:17, Thomas Graf wrote:
> * jamal <1108994621.1089.158.camel@jzny.localdomain> 2005-02-21 09:03
> > 
> > Everything in the stack would have to be re-written not just that one
> > piece. 
> > The question is: Is it worth it? My experimentation shows, only in a few
> > speacilized cases.
> 
> Assuming we can deliver a chain of skbs to enqueue (session based or not),
> the locking times should decrease. I'm not sure whether it's worth to
> rewrite the whole stack (I wouldn't have any use for it) or just establish
> a fast path. We could for example allow the ingress qdisc to redirect
> packets directly to a egress qdisc and have "dynamic" fast forwarding.
> We can add an action looking up the route and rewriting the packet as
> needed and enqueue it to the right qdisc immediately. The redirect action
> is already on that way, now if we can reduce the locking overhead a bit
> more the fast forwarding routing t-put should increase.
> 
