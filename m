From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 12:37:50 -0700
Message-ID: <20140506193750.GA21332@cloud>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
 <20140505.231229.136734008603421707.davem@davemloft.net>
 <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140506183216.GM19657@tassilo.jf.intel.com>
 <CA+mtBx81EdtZeXRG_ubgWMy+8rSOpK3q0S3YktBDDFt-LG2poA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@linux.intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, tom.zanussi@linux.intel.com
To: Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+mtBx81EdtZeXRG_ubgWMy+8rSOpK3q0S3YktBDDFt-LG2poA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 06, 2014 at 11:58:38AM -0700, Tom Herbert wrote:
> On Tue, May 6, 2014 at 11:32 AM, Andi Kleen <ak@linux.intel.com> wrote:
> >> We simply can not compete with user space, as a programmer is free to
> >> keep what he really wants/needs.
> >
> > Not true.
> >
> > With my patches and LTO Linux can be competive with LWIP+socket layer.
> > (about 60K more text). And it's easier to use because it's just
> > the standard interface.
> >
> >> I have started using linux on 386/486 pcs which had more than 2MB of
> >> memory, it makes me sad we want linux-3.16 to run on this kind of
> >> hardware, and consuming time to save few KB here and here.
> >
> > Linux has always been a system from very small to big.
> > That's been one of its strengths. It is very adaptable.
> >
> > Many subsystems are very configurable for this.
> > For example that is why we have both SLOB and SLUB.
> > That is why we have NOMMU MM and lots of other tuning
> > knobs for small systems.
> >
> > So if the other subsystems can do this, why should it be
> > impossible for networking?
> >
> Can this at least be done without the combinatorial explosion in
> number of configurations? As Yuchung pointed out these patches
> introduce at least one unresolved configuration dependency. CONFIG_SMP
> works quite well since with a single parameter we can enable/disable a
> whole bunch of functionality in bulk, and it's quite clear that new
> development cannot break smp or non-smp configurations. Maybe you want
> something similar like CONFIG_NETWORK_SMALL?

That seems completely reasonable.  Likewise, for infrastructure that
scales by CPU, keying off of CONFIG_NR_CPUS might make sense.

I'd suggest inverting it, so that 'n' means "small" and 'y' means fully
featured.  Here's a rough description for a CONFIG_NETWORK_FULL:

config NETWORK_FULL
	default y
	bool "Full-featured networking stack" if EMBEDDED
	--help--
	  Leave this option enabled for a full-featured networking
	  stack, including features used by the vast majority of
	  systems.  Saying N here results in a minimal embedded
	  networking stack, suitable only for the most
	  memory-constrained and storage-constrained systems; the
	  minimal stack removes many features, and optimizes for code
	  and data size rather than performance.

	  If in doubt, say Y here.
