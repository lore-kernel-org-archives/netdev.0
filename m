From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 11:49:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119194943.GA9360@bougret.hpl.hp.com>
References: <20040119123343.GA16292@colin2.muc.de> <20040119123945.A32623@infradead.org> <20040119141041.2cccbc3d.ak@suse.de> <20040119055615.4380e157.davem@redhat.com> <20040119153919.14102937.ak@suse.de> <20040119063921.586b37ac.davem@redhat.com> <20040119155412.2bffee5a.ak@suse.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, hch@infradead.org, ak@colin2.muc.de,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040119155412.2bffee5a.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2004 at 01:33:43PM +0100, Andi Kleen wrote:
> 
> Some distributions call iwconfig at every bootup and I was sick of 
> seeing all the unimplemented ioctl messages on AMD64 with a 32bit userland.
> 
> This patch implements ioctl emulation for the wireless subsytem.
> The only structure that was incompatible from visual inspection was
> "iw_point". The rest is just passed through.
> 
> It reuses the existing ioctl description table, but renames it to 
> export it (standard_ioctls wasn't a good name for a global variable) 

	I'm glad that you found the ioctl description table useful,
the code look neat and simple. When I did redesign the driver API in
WE-13, ioctl emulation for 64 bits was definitely on my mind (thanks
to Dave warning me about it). Also, from the very start, the API was
defined with explicitely sized types, which help.

	However, this is my prefered way to do things. I would much
prefer to see you using native version of the Wireless Tools,
especially that the tools and the kernel need to be in sync as far as
version is concerned. It should be a simple matter of recompiling the
tools package.
	One of the main strength of OpenSource is that you can
recompile for your platform, and I think we should fully exploit this
advantage, especially for the base system. Otherwise, why not enable
16bit compatibility on i386 for ELKS packages ?

> I don't actually have have a working wireless card (only some non supported
> Samsung one), so I wasn't able to test it, but at least the messages
> are gone.

	Actually, the devil is always in the details.

On Mon, Jan 19, 2004 at 03:54:12PM +0100, Andi Kleen wrote:
> On Mon, 19 Jan 2004 06:39:21 -0800
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > On Mon, 19 Jan 2004 15:39:19 +0100
> > Andi Kleen <ak@suse.de> wrote:
> > 
> > > Went it in after 2.6.1?
> > 
> > Yes, Linus sucked it in like 10 hours ago, about 4 hours right before you made
> > your initial posting on this thread.
> 
> Oh, I actually posted it yesterday but due a broken MTA it didn't go out @)
> But I didn't check BK anyways so it would not have made much difference.
> 
> -Andi

	It seems that the BK->Web stuff has not yet picked your
updates, because I don't see them (and of course the snapshot on
kernel.org is too old).
	Let's just be happy that some code is in ;-)

	Regards,

	Jean
