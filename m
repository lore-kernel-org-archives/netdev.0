From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: Multicast and receive filtering in TUN/TAP
Date: Fri, 11 Jul 2008 01:01:58 -0700
Message-ID: <48771376.4020401@qualcomm.com>
References: <4875428F.4080704@qualcomm.com> <200807102223.40717.borntraeger@de.ibm.com> <4876C357.3030708@qualcomm.com> <200807111701.39070.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	virtualization@lists.linux-foundation.org,
	Brian Braunstein <linuxkernel@bristyle.com>,
	Shaun Jackman <sjackman@gmail.com>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:21429 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbYGKIB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 04:01:59 -0400
In-Reply-To: <200807111701.39070.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Friday 11 July 2008 12:20:07 Max Krasnyansky wrote:
>>>> I haven't looked at the virtio stuff much, I was assuming that the host
>>>> side of it is still the TUN driver. Is it not ?
>>> Yes, the host side is still tun/tap. The problem is that qemu doesnt know
>>> which multicast addresses are used inside the guest.
>> Ah, now I see what you meant by virtio_net does not do multicast. I guess
>> it should trivial to add. Rusty will clarify it I guess.
> 
> Yes, it could certainly be added; that's what feature bits are for :)

Sounds good.
I'll send the patch that lets you guys setup tx filters on the TAP devices.
Hypervisors will then need to translate rx filters set by the guest OS into
TAP tx filters. I'm thinking of doing it just like E1000 for example. 14 exact
filters and the rest is hashed.

Max
