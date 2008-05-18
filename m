From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses
	ofIRQF_SAMPLE_RANDOM
Date: Sun, 18 May 2008 17:43:40 +0300
Message-ID: <20080518144340.GH8140@cs181133002.pp.htv.fi>
References: <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <20080516161029.44ded734@core> <0f7201c8b790$9c2a2340$f9b5a8c0@pii350> <20080517220258.GC8140@cs181133002.pp.htv.fi> <10a001c8b8b2$28afd2c0$f9b5a8c0@pii350> <20080518120235.GE8140@cs181133002.pp.htv.fi> <20080518122410.GA31413@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Theodore Tso <tytso@mit.edu>, Gilles Espinasse <g.esp@free.fr>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756909AbYEROpw@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080518122410.GA31413@mit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 18, 2008 at 08:24:10AM -0400, Theodore Tso wrote:
> On Sun, May 18, 2008 at 03:02:36PM +0300, Adrian Bunk wrote:
> > > Yes that's the whole point.
> > > Why remove IRQF_SAMPLE_RANDOM if "it cannot make the RNG output worse."
> > > We should not care if network traffic can be sniffed in some configurations
> > > (plus sniffing could be very unlikely in some others).
> > >...
> > > Are network drivers better without SAMPLE_RANDOM?
> > > My understanding of openssl developper answer is same as yours :
> > > "it cannot make the RNG output worse."
> > 
> > The "it cannot make the RNG output worse." only applies to the OpenSSL 
> > case (one could argue whether it makes sense, but it can't do harm).
> 
> Actually, it applies here too.  Or it can be made to apply here.  If
> people are concerned that for certain cards the entropy could
> potentially be guessed by someone on the local network (although I
> suspect it's still useful for protecting against someone who doesn't
> have local network access), we could still sample the entropy, and
> just not increment the entropy credit for /dev/random's sake.

The latter is exactly the difference between the two cases.

But Gilles was implying using IRQF_SAMPLE_RANDOM for gathering entropy 
was as harmless as OpenSSL mixing uninitialized memory into their RNG.

> It will
> still put something into the entropy pool which is also used by
> /dev/urandom.
> 
> > The replacement solution ready on all Linux machines today is for 
> > userspace to use /dev/urandom instead of /dev/random if feasible.
> 
> Sampling interrupt entropy will definitely not hurt /dev/urandon, and
> may help, especially in the freshly installed server case.  Especially
> if it's using kickstart-style install, where there is no keyboard
> entropy, sampling the interrupts as it pulls RPM's from the network
> and/or the CD-ROM drive may be all that we have.

No disagreement on this.

>               	   	  	       	   	   - Ted

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
