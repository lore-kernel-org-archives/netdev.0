From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Wed, 2 Feb 2005 14:28:16 +0100
Message-ID: <20050202132816.GP31837@postel.suug.ch>
References: <1107123123.8021.80.camel@jzny.localdomain> <20050131135810.GC31837@postel.suug.ch> <1107181169.7840.184.camel@jzny.localdomain> <20050131151532.GE31837@postel.suug.ch> <41FED514.7060702@dsl.pipex.com> <20050201133138.GM31837@postel.suug.ch> <41FF9A55.4080005@dsl.pipex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
Content-Disposition: inline
In-Reply-To: <41FF9A55.4080005@dsl.pipex.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >>WRT policers I never figured out where you would put the effects of 
> >>playing with the burst size parameter and it's effects with few/many 
> >>connections and any burstiness caused into an equasion like that.
> >
> >
> >A burst buffer has impact on R on later packets, it can "smooth" R
> >and X and thus results in more stable rates. Depending on the actual
> >burst, it can avoid retransmits which stabilizes the rate as well.
> 
> But it's not a real rate limiting buffer in the policer case is it?

Abstractly speaking, burst specifies the maximum amount of time allowed
for a single packet to sit in the burst buffer. Although the burst is
configured as the size of the buffer it is transformed into a time
delta before providing it to the kernel. Because the policer doesn't
enqueue things the packet simply gets dropped if it would exceed that
time. It's not _exactly_ like this but it gives you an idea what
happens, net/sched/police.c isn't that big so one coffee should do it.

> Nice - are you planning to add anything to tweak things for the wrong 
> end of the bottleneck problems?

I hope so, once I figured out an acceptable compromise between a good
result and simplicity. Currently it would be way to expensive and hard
to use.
