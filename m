From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Intel and TOE in the news
Date: Mon, 21 Feb 2005 15:17:14 +0100
Message-ID: <20050221141714.GV31837@postel.suug.ch>
References: <20050220230713.GA62354@muc.de> <200502210332.j1L3WkDD014744@guinness.s2io.com> <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch> <1108994621.1089.158.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Leonid Grossman <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1108994621.1089.158.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1108994621.1089.158.camel@jzny.localdomain> 2005-02-21 09:03
> 
> Everything in the stack would have to be re-written not just that one
> piece. 
> The question is: Is it worth it? My experimentation shows, only in a few
> speacilized cases.

Assuming we can deliver a chain of skbs to enqueue (session based or not),
the locking times should decrease. I'm not sure whether it's worth to
rewrite the whole stack (I wouldn't have any use for it) or just establish
a fast path. We could for example allow the ingress qdisc to redirect
packets directly to a egress qdisc and have "dynamic" fast forwarding.
We can add an action looking up the route and rewriting the packet as
needed and enqueue it to the right qdisc immediately. The redirect action
is already on that way, now if we can reduce the locking overhead a bit
more the fast forwarding routing t-put should increase.
