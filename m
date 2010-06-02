From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Wed, 02 Jun 2010 22:52:28 +0300
Message-ID: <1275508348.2797.26.camel@powerslave>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>
	 <1275503835.1574.0.camel@powerslave> <1275505553.2797.2.camel@powerslave>
	 <alpine.LSU.2.01.1006022127430.32028@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1006022127430.32028@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-02 at 21:29 +0200, ext Jan Engelhardt wrote:
> On Wednesday 2010-06-02 21:05, Luciano Coelho wrote:
> >> > >+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
> >> > >+						   &THIS_MODULE->mkobj.kobj);
> >> > 
> >> > Isn't this going to oops when you compile this module as =y?
> >> 
> >> Damn, that's true. :(
> >> 
> >> I'll investigate how to fix this.
> >
> >Would it be too hacky to force it to be a module (ie. add "depends on m"
> >in Kconfig)?
> >
> >Besides /sys/module/xt_IDLETIMER and /sys/class/net, which we have
> >already discarded, I can't find any other place that would make sense to
> >add the idletimer in the kernel object hierarchy...
> 
> While THIS_MODULE is NULL in =y mode, /sys/module/<xyz> can still exist 
> (cf. /sys/module/printk). I just don't know how to get at the kobj for 
> it, but the existence of it must mean it's there somewhere. Might ask 
> sysfs authors.

Okay, good to know.  My initial theory was that /sys/module/xt_IDLETIMER
(pointed to by THIS_MODULE) would exist even if it was linked into the
kernel itself, but now it's obvious that it doesn't.

I'll investigate how printk does that.

-- 
Cheers,
Luca.

