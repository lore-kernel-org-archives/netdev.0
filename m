From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Wed, 2 Jun 2010 21:29:10 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006022127430.32028@obet.zrqbmnf.qr>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>  <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>  <1275503835.1574.0.camel@powerslave> <1275505553.2797.2.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275505553.2797.2.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-06-02 21:05, Luciano Coelho wrote:
>> > >+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
>> > >+						   &THIS_MODULE->mkobj.kobj);
>> > 
>> > Isn't this going to oops when you compile this module as =y?
>> 
>> Damn, that's true. :(
>> 
>> I'll investigate how to fix this.
>
>Would it be too hacky to force it to be a module (ie. add "depends on m"
>in Kconfig)?
>
>Besides /sys/module/xt_IDLETIMER and /sys/class/net, which we have
>already discarded, I can't find any other place that would make sense to
>add the idletimer in the kernel object hierarchy...

While THIS_MODULE is NULL in =y mode, /sys/module/<xyz> can still exist 
(cf. /sys/module/printk). I just don't know how to get at the kobj for 
it, but the existence of it must mean it's there somewhere. Might ask 
sysfs authors.
