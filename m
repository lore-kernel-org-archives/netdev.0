From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] Merge p80211 to ieee80211 subsystem
Date: Mon, 28 Mar 2005 06:53:34 -0800
Message-ID: <20050328145334.GE8180@jm.kir.nu>
References: <1111740953.17276.84.camel@debian.sh.intel.com> <20050327023706.GH8204@jm.kir.nu> <1111994365.17276.205.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <1111994365.17276.205.camel@debian.sh.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2005 at 03:19:25PM +0800, Zhu Yi wrote:

> > - Native WPA/802.11i?
> > 
> > What do you mean with this?
> 
> Handling EAP, EAPOL in the stack.

Why would that be in kernel? I don't really see much point in moving
things like TLS and user certificates, SIM card authentication, and so
on into the kernel.

> With the native 802.11 stack, the link layer will return 802.11 packets
> instead of 802.3 packets. If wpa_supplicant is involved in setting up
> WPA/802.11i, it has to encrypt and decrypt EAPOL packets like it does
> currently. I didn't look into WME/802.11e much and don't see how it
> involves here. But moving EAPOL code into the stack will resolve the
> problem.

wpa_supplicant does not encrypt or decrypt any packets, nor would it
even be able to since it does not have all the needed information for
this (packet sequence numbers and possibility to insert one of those).
These are just normal data frames that should be taken care of by the
802.11 stack. From my viewpoint, moving EAPOL code into the stack would
not be solution, but another problem.

WMM/IEEE 802.11e changes the packet header, so if user space programs
are required to parse/generate them, they would also need to know how to
parse these additional fields and even more importantly, when to add
them..

> > dev->type is set to ARPHRD_ETHER. Shouldn't it be something else? How
> > does user space know what kind of frames to expect?
> 
> This is mentioned in the comment. I didn't set dev->type to
> ARPHRD_IEEE80211 here just keep the compatibility with other devices.
> For example, some APs will think this is a wrong ARP type and discard
> the packet. But most user space programs won't be affected by this if
> they don't play with ARP.

But all user space programs looking at link layer headers will be
confused.. If the net device is not looking like wired Ethernet anymore,
its type should not claim so either.

> Yes, this is debug code, we can just remove it at this time. For whether
> or not it is wise to support EAPOL in the stack, can you share some of
> your viewpoints?

Well, you probably have already figured out from my comments above that
I'm against this. I see no benefit in moving EAPOL/EAP processing into
kernel. We are talking about 20k lines of code (not including TLS
library) here for just the currently used EAP methods.. In addition, one
would need to provide mechanism for configuring certificates, smart card
access, etc. for the kernel to do. All of this is much easier to do in
user space as far as I can tell.

What benefits do you see in having EAPOL/EAP implemented in network
stack? Did you see it being adding as part of 802.11 stack or network
stack in general? IEEE 802.1X/EAPOL is used also on wired interfaces..

-- 
Jouni Malinen                                            PGP id EFC895FA
