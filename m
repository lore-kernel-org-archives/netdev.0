From: Dave Jones <davej@redhat.com>
Subject: Re: [2.6 patch] schedule SHAPER for removal
Date: Sun, 22 Jan 2006 16:21:26 -0500
Message-ID: <20060122212126.GC32701@redhat.com>
References: <20060119021150.GC19398@stusta.de> <20060119215722.GO16285@kvack.org> <20060121004848.GM31803@stusta.de> <20060122174707.GC1008@kvack.org> <20060122182034.GG10003@stusta.de> <1137954776.3328.31.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, Benjamin LaHaise <bcrl@kvack.org>,
	Andrew Morton <akpm@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750765AbWAVVXJ@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1137954776.3328.31.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 22, 2006 at 07:32:56PM +0100, Arjan van de Ven wrote:

 > > The only supported combinations are distributions with the kernels they 
 > > ship.
 > 
 > I think you're being unreasonable here.

Absolutely. The statement is also completely false.
Fedora rebases to a new point release shortly after they become available
(in reality usually just after the .1 -stable release).
At least part of the reason is that with 3-4000 changes going in upstream
per release, the amount of work backporting fixes is just totally impractical.

I just looked over feature-removal-schedule.txt for things that are probably
going to impact us due to our rebasing.

The only thing there that could cause major heartburn for FC4 users is
Dominik's proposal to remove PCMCIA control ioctl (scheduled for Last November).

Migrating already working setups from pcmcia-cs to pcmcia-utils when an
update kernel gets pushed out gives me the creeps, especially as we're still
not at a state where 'everything works' in our FC5-development branch.
(I'd feel more comfortable retrofitting this after its been through a stable
 distro release and got a lot of exposure).
So if the old pcmcia code got ripped out in 2.6.17, chances are I'd carry
a 'revert this bunch of changes' patch for future FC4 updates.
Not that big a deal, but probably a days work to build & test,
plus ongoing maintainence to rediff the patch on future updates.

Pretty much everything else there is either only of impact to out-of-tree
modules, for which I couldn't really care less, or they're bits of functionality
that we have moved off already, or have disabled. (Though I'm not entirely
sure everything has moved off of V4L1 yet without going and checking)

 > In addition I think that in case such a feature isn't actually
 > harmful of further development (for example, it could be because it's
 > fundamentally broken locking wise, or holding back major improvements)
 > then a longer period of warnings should be no problem.  Together with
 > that should probably be something to ask distros to stop enabling the
 > feature asap, or at least communicate it as deprecated in their
 > respective release notes.

Sounds very practical, and something I'd be totally open to doing for Fedora.

		Dave
