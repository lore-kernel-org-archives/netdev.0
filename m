From: Ruben Kerkhof <ruben@rubenkerkhof.com>
Subject: Re: EPT: Misconfiguration
Date: Sat, 5 Mar 2011 19:57:43 +0100
Message-ID: <AANLkTin=JK1+CG5by+vWxnYP+vYJpn8YHGGMLSzqFNEs@mail.gmail.com>
References: <AANLkTinjt8G=mdEZK1a3qKozHw24uN0dfy2vUckbqwSZ@mail.gmail.com>
 <20110121132247.GA3097@amt.cnet> <AANLkTi=kMRu+4V6cc3bZtAT-L2P5cUo0QR3wNR3Y4u6B@mail.gmail.com>
 <4D3F0AD1.9010903@redhat.com> <AANLkTi=RMXSHAAbnN=HykGqbUshOFX_DO4kgYXTZUAdR@mail.gmail.com>
 <4D3FEEDB.5070407@redhat.com> <AANLkTimhkuMeKuihwRVnphxdCejpGi3rgd3uj9Xc_70v@mail.gmail.com>
 <AANLkTik76qykBCS_sEDQvBr4n7=BuffiU23bYKjFTRxa@mail.gmail.com>
 <AANLkTikS2M2pxO09PHN8+5+cBaQ593C9H7KthQHd4tM0@mail.gmail.com>
 <4D57D6AC.7000608@redhat.com> <20110215171639.GA12842@amt.cnet>
 <AANLkTimeFf2Smj=bWDYoH0Hf+ftnbW3XjacyS2pu49_o@mail.gmail.com>
 <AANLkTiknMneQtYqgmX7gvXsMoSO-yiLXr-dwbEej80Uy@mail.gmail.com> <4D6A2B91.5020100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Tosatti <mtosatti@redhat.com>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4D6A2B91.5020100@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 27, 2011 at 11:46, Avi Kivity <avi@redhat.com> wrote:
>
> Copying netdev: looks like memory corruption in the networking stack.
>
> Archive link: http://www.spinics.net/lists/kvm/msg50651.html (for the
> attachment).

There's now only a single guest running on this host (Ubuntu Maverick).
I've also upgraded the host kernel to 2.6.38-rc6, and this just
happened (after a day or so):

2011-03-05T19:41:58.328866+01:00 phy005 kernel: [85271.656862] BUG
kmalloc-2048 (Not tainted): Object padding overwritten
2011-03-05T19:41:58.328870+01:00 phy005 kernel: [85271.656864]
-----------------------------------------------------------------------------
2011-03-05T19:41:58.328875+01:00 phy005 kernel: [85271.656866]
2011-03-05T19:41:58.328885+01:00 phy005 kernel: [85271.656870] INFO:
0xffff880c0d52a960-0xffff880c0d52a967. First byte 0x0 instead of 0x5a
2011-03-05T19:41:58.328890+01:00 phy005 kernel: [85271.656880] INFO:
Allocated in __netdev_alloc_skb+0x1f/0x3b age=16039 cpu=5 pid=0
2011-03-05T19:41:58.328894+01:00 phy005 kernel: [85271.656886] INFO:
Freed in skb_release_data+0xa5/0xaa age=0 cpu=5 pid=1766
2011-03-05T19:41:58.328898+01:00 phy005 kernel: [85271.656890] INFO:
Slab 0xffffea002a2ea0c0 objects=15 used=13 fp=0xffff880c0d52a120
flags=0xc00000000040c1
2011-03-05T19:41:58.328902+01:00 phy005 kernel: [85271.656894] INFO:
Object 0xffff880c0d52a120 @offset=8480 fp=0xffff880c0d52d2d0
2011-03-05T19:41:58.328905+01:00 phy005 kernel: [85271.656895]
2011-03-05T19:41:58.328909+01:00 phy005 kernel: [85271.656897] Bytes
b4 0xffff880c0d52a110:  14 89 12 05 01 00 00 00 5a 5a 5a 5a 5a 5a 5a
5a ........ZZZZZZZZ
2011-03-05T19:41:58.328913+01:00 phy005 kernel: [85271.656909]
Object 0xffff880c0d52a120:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
6b 6b kkkkkkkkkkkkkkkk

We have a quite complex network stack, two interfaces (igb) attached
to bond0, with on top two bridges and on that two vlans.
The guest is running a vpn and an IPv6 tunnel.

Let me know if more info is needed.

Kind regards,

Ruben
