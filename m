From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 00:55:17 +0300
Message-ID: <20080515215517.GI1936@cs181133002.pp.htv.fi>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mpm@selenic.com
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763597AbYEOV5S@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2008 at 09:07:52AM -0700, Brandeburg, Jesse wrote:
> Alan Cox wrote:
> > Chris Peterson <cpeterso@cpeterso.com> wrote:
> >> I know Jeff Garzik says he's not interested in an anti-entropy
> >> pogrom for existing net drivers, but here is the patch if anyone
> >> else is interested..? :)  
> >> 
> >> Only 12 net drivers are affected, the last of the
> >> theoretically-exploitable network entropy. 
> > 
> > Looks fine to me. If Jeff doesn't want to touch them then send them
> > direct to Andrew/Linus.
> > 
> > A more interesting alternative might be to mark things like network
> > drivers with a new flag say IRQF_SAMPLE_DUBIOUS so that users can be
> > given a switch to enable/disable their use depending upon the
> > environment. 
> 
> we've been hearing rumblings of big customers wanting (maybe requiring)
> wired network drivers from Intel to  advertise this flag.  Jeff have you
> heard of such?
> 
> I think the argument is that a headless system (no keyboard/mouse, no
> soundcard, probably no video) with a libata based driver and a network
> driver without IRQF_SAMPLE_RANDOM has *no* sources of entropy.  In this
> case the argument is very strong for at least *some* source of entropy
> from interrupts so that randomness can get some external input.  Just
> try rebuilding a kernel RPM over an ssh session and you'll see what I
> mean.
> 
> In short, I agree with Alan's IRQF_SAMPLE_DUBIOUS, and know of Linux
> customers who also want the same.

We have two random number interfaces:
- /dev/random
- /dev/urandom

If a customer wants to get data from /dev/random although there's not 
enough entropy that's not a problem we can solve (we can only try to 
gather more real entropy if possible).

If he can live with dubious data he can simply use /dev/urandom .

If a customer wants to use /dev/random and demands to get dubious data 
there if nothing better is available fulfilling his wish only moves 
the security bug from his crappy application to the Linux kernel.

But what we could perhaps do with some kind of IRQF_SAMPLE_DUBIOUS would 
be to improve the quality of the data in /dev/urandom if there's not 
enough entropy available?

I have seen embedded systems with zero entropy, and dubious entropy 
might there be better than no entropy at all.
Or am I wrong on the latter?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
