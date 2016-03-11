From: Edward Cree <ecree@solarflare.com>
Subject: Generic TSO (was Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer
 Tx checksum by default)
Date: Fri, 11 Mar 2016 19:20:41 +0000
Message-ID: <56E31A89.9020602@solarflare.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAEh+42jHjEqjEyN3-OopZK2hAowh4LGKSgZWgSe9+W1zdezpZA@mail.gmail.com>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
 <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
 <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
 <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:50742 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983AbcCKTUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:20:51 -0500
In-Reply-To: <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/02/16 19:51, Tom Herbert wrote:
> Right. To use LCO with TSO we would need to ensure that all packets
> are the same size so that the UDP length field and thus checksum are
> constant for all created segments. But this property this would also
> make any payload lengths in headers constant for all packets so that
> the only fields that need be set per generated packet would be the TCP
> sequence number and checksum. This simplifying assumption could be
> used to make a very protocol-generic GSO/TSO (up to the transport
> header)!
>
> Conceptually, a device would just need to know the start of the
> packet, the offset of the transport header, and the size of each
> segment. Any bits from the start of the packet to the beginning of the
> transport header are just copied to each segment, so any combination
> of encapsulation/network protocols is  supported as long as they are
> constant for each segment (e.g. MPLS, NSH, etc. are on the horizon for
> needing TSO support).
Tom,

Are you planning to / working on implementing this?  If not, I might have a
crack at it; I've talked to our firmware guys and (provisionally) we think
we can support it in current sfc hardware.
Or were there any blocking problems raised in the thread?  My understanding
of the IP ID issue was that it only matters for the inner frame, because
the rest aren't TCP (so hopefully no-one is doing SLHC on them).  But I may
have missed something.

-Ed
