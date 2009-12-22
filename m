From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 08:57:42 +0100
Message-ID: <20091222075742.GB26467@elte.hu>
References: <4B1D4F29.8020309@gmail.com>
 <20091218215107.GA14946@elte.hu>
 <4B2F9582.5000002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752989AbZLVH60@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B2F9582.5000002@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Gregory Haskins <gregory.haskins@gmail.com> wrote:

> On 12/18/09 4:51 PM, Ingo Molnar wrote:
> > 
> > * Gregory Haskins <gregory.haskins@gmail.com> wrote:
> > 
> >> Hi Linus,
> >>
> >> Please pull AlacrityVM guest support for 2.6.33 from:
> >>
> >> git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git
> >> for-linus
> >>
> >> All of these patches have stewed in linux-next for quite a while now:
> >>
> >> Gregory Haskins (26):
> > 
> > I think it would be fair to point out that these patches have been objected to 
> > by the KVM folks quite extensively,
> 
> Actually, these patches have nothing to do with the KVM folks. [...]

That claim is curious to me - the AlacrityVM host is 90% based on KVM code, so 
how can it not be about KVM? I just checked, most of the changes that 
AlacrityVM host does to KVM is in adding the host side interfaces for these 
guest drivers:

 virt/kvm/Kconfig          |   11 +
 virt/kvm/coalesced_mmio.c |   65 +++---
 virt/kvm/coalesced_mmio.h |    1 +
 virt/kvm/eventfd.c        |  599 +++++++++++++++++++++++++++++++++++++++++++++
 virt/kvm/ioapic.c         |  118 +++++++--
 virt/kvm/ioapic.h         |    5 +
 virt/kvm/iodev.h          |   55 +++--
 virt/kvm/irq_comm.c       |  267 ++++++++++++++-------
 virt/kvm/kvm_main.c       |  127 ++++++++--
 virt/kvm/xinterface.c     |  587 ++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 1649 insertions(+), 186 deletions(-)

 [ stat for virt/kvm/ taken as of today, AlacrityVM host tree commit 84afcc7 ]

So as far as kernel code modifications of AlacrityVM goes, it's very much 
about KVM.

> [...]  You are perhaps confusing this with the hypervisor-side discussion, 
> of which there is indeed much disagreement.

Are the guest drivers living in a vacuum? The whole purpose of the AlacrityVM 
guest drivers is to ... enable AlacrityVM support, right? So how can it be not 
about KVM?

Gregory, it would be nice if you worked _much_ harder with the KVM folks 
before giving up. It's not like there's much valid technical disagreement that 
i can identify in any of the threads - the strongest one i could identify was: 
"I want to fork KVM so please let me do it, nobody is harmed, choice is good".

	Ingo
