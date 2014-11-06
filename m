From: Ulf samuelsson <netdev@emagii.com>
Subject: Re: How to make stack send broadcast ARP request when entry is STALE?
Date: Thu, 6 Nov 2014 14:29:55 +0100
Message-ID: <B5AF87A6-42A4-44A3-A7DB-8FCB7754FBEB@emagii.com>
References: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com> <CACP96tQpnqfVtNwQbB9U4e-OLto3LhhS2q0bBir4n4Qz11XMTg@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out11.han.skanova.net ([195.67.226.200]:44227 "EHLO
	smtp-out11.han.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751133AbaKFNaF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 08:30:05 -0500
In-Reply-To: <CACP96tQpnqfVtNwQbB9U4e-OLto3LhhS2q0bBir4n4Qz11XMTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Best Regards
Ulf Samuelsson
ulf@emagii.com
+46  (722) 427 437


> 6 nov 2014 kl. 12:48 skrev Sowmini Varadhan <sowmini05@gmail.com>:
> 
>> On Wed, Nov 5, 2014 at 1:48 AM, Ulf samuelsson <netdev@emagii.com> wrote:
>> Have a problem with an HP router at a certain location, which
>> is configured to only answer to broadcast ARP requests.
>> That cannot be changed.
>> 
>> The first ARP request the kernel sends out, is a broadcast request,
>> which is fine, but after the reply, the kernel sends unicast requests,
>> which will not get any replies.
> 
> I'm afraid that's a problem with your HP router. There is nothing
> in RFC 826 that says that the ARP request MUST be broadcast,
> and many OS'es  will follow the IPv6 ND model of sending
> unicast ARP requests to re-verify cached arp information.
> Looks like the "kernel" you refer to above is following this
> state machine, which is a good and healthy thing- you dont
> want to be needlessly broadcasting arp reverification requests.
> 

The router setup will not be changed, not my decision. i have to live with it.
The issue occurs only on a backplane, implemented using network,
so consequences of broadcast ARP if unicast ARP fails is known, and acceptable,

Since the controlling mechanism is a kernel module
it would make sense to use the native stack, instead of trying to duplicate the functionality.

If I dont want any broadcast ARP, there is a mcast_probes /proc variable that can be changed
to zero (default 3).

As it is now, it look like mcast_probes is there, but it is not used at all by the kernel,
so it should either be removed, or the intended functionality should work

It is strange, that if even if it is acceptable with broadcast ARP,
you cannot configure the kernel code, nor the kernel runtime
to generate it.

I think the kernel should be changed to have a compile time option
allowing broadcast ARP to be sent, if mcast_probes > 0.
Alternatively a new variable should be introduced which will allow sending broadcast ARP
if the unicast ARP fails,

Will implement that fix locally anyway.

> thus even if you have access to the kernel source code (as with linux)
> it's not recommended to broadcast the ARP reverification.
> 
>> The ARP entry will after some time enter STALE state,
>> and if nothing is done it will time out, and be removed.
> :
> 
>> I think the recommended behaviour in IPv6 is to send out 3 unicasts
>> and if all fails, to send out broadcasts.
> 
> Be careful about the distinction between IPv4 ARP and IPv6 ND.
> The base state-machine for IPv6 is explicitly specified in RFC 4861 (with
> ongoing work to optimize some of this in various ietf working groups)
> 
> The territory is less clearly defined for ARP. The base protocol comes from
> RFC 726, which does not address DAD  at all- that only comes from rfc 5227.
> Some OS-es (solaris, microsoft?) implelement the same state-machine
> for both IPv4 and IPv6, while also support 5227.
> 
>> 
>> Anyone know any good literature on how the ARP + neigh state machine works
>> in the kernel.
>> 
>> I read in Herberts book about the Linux TCP/IP stack and it only discuss how to reply to
>> ARP requests and not anything on how to generate ARP requests.
> 
> Hope that helps.
> 
> --Sowmini
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
