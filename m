From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Thu, 03 Jun 2010 10:04:20 +0300
Message-ID: <1275548660.10855.4.camel@chilepepper>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>
	 <1275503835.1574.0.camel@powerslave> <1275505553.2797.2.camel@powerslave>
	 <alpine.LSU.2.01.1006022127430.32028@obet.zrqbmnf.qr>
	 <1275508348.2797.26.camel@powerslave> <1275509088.2797.29.camel@powerslave>
	 <1275512485.2797.46.camel@powerslave>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275512485.2797.46.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-02 at 23:01 +0200, Coelho Luciano (Nokia-D/Helsinki)
wrote:
> On Wed, 2010-06-02 at 22:04 +0200, Coelho Luciano (Nokia-D/Helsinki)
> wrote:
> > What causes printk to appear under /sys/module even when compiled in, is
> > that it uses a module param.  This line:
> > 
> > module_param_named(time, printk_time, bool, S_IRUGO | S_IWUSR);
> > 
> > ...is what triggers the printk directory to be created in sysfs.  If I
> > add a similar line in my module, it shows up there too.
> > 
> > I still don't know if there is an actual kobject associated with it,
> > I'll check that next.
> 
> Okay, so here is how it goes: if the module is linked into the kernel
> and it has module parameters, the kernel creates a kobj for it as a
> module_ktype without parent, which will cause it to show up
> in /sys/modules.
> 
> I could do the same in the module initialization when THIS_MODULE ==
> NULL, but I don't see any other module doing this.  In fact, I only see
> the kernel itself creating kobjects of module_ktype (in load_module()
> and in the case I just described).  Smells like a terrible hack to do
> that in the module itself... :(
> 
> Adding bogus parameters to the module just to trig the kernel to create
> the kobject also seems to be too hacky...

Looking closer, it seems that it makes a bit of sense to add a kernel
module to /sys/device/system.  I think it makes more sense than adding
to the module class or to the net class, actually.  The idletimer is not
a net device (so it doesn't fit in /sys/class/net) and it is not a
module, even though it may be handled by the xt_IDLETIMER module.

So we can look at the xt_idletimer as a system device, which is not a
peripheral device in itself, but a software timer device (there are
already similar components).

I'll add the kernel object we need as a system class device, so it will
go under /sys/devices/system/xt_idletimer.  Does that make sense to you?


-- 
Cheers,
Luca.

