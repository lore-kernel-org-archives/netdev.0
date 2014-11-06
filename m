From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: How to make stack send broadcast ARP request when entry is STALE?
Date: Thu, 6 Nov 2014 06:48:15 -0500
Message-ID: <CACP96tQpnqfVtNwQbB9U4e-OLto3LhhS2q0bBir4n4Qz11XMTg@mail.gmail.com>
References: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Ulf samuelsson <netdev@emagii.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:64283 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbaKFLsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 06:48:17 -0500
Received: by mail-la0-f46.google.com with SMTP id gm9so2380098lab.5
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 03:48:15 -0800 (PST)
In-Reply-To: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014 at 1:48 AM, Ulf samuelsson <netdev@emagii.com> wrote:
> Have a problem with an HP router at a certain location, which
> is configured to only answer to broadcast ARP requests.
> That cannot be changed.
>
> The first ARP request the kernel sends out, is a broadcast request,
> which is fine, but after the reply, the kernel sends unicast requests,
> which will not get any replies.

I'm afraid that's a problem with your HP router. There is nothing
in RFC 826 that says that the ARP request MUST be broadcast,
and many OS'es  will follow the IPv6 ND model of sending
unicast ARP requests to re-verify cached arp information.
Looks like the "kernel" you refer to above is following this
state machine, which is a good and healthy thing- you dont
want to be needlessly broadcasting arp reverification requests.

thus even if you have access to the kernel source code (as with linux)
it's not recommended to broadcast the ARP reverification.

> The ARP entry will after some time enter STALE state,
> and if nothing is done it will time out, and be removed.
 :

> I think the recommended behaviour in IPv6 is to send out 3 unicasts
> and if all fails, to send out broadcasts.

Be careful about the distinction between IPv4 ARP and IPv6 ND.
The base state-machine for IPv6 is explicitly specified in RFC 4861 (with
ongoing work to optimize some of this in various ietf working groups)

The territory is less clearly defined for ARP. The base protocol comes from
RFC 726, which does not address DAD  at all- that only comes from rfc 5227.
Some OS-es (solaris, microsoft?) implelement the same state-machine
for both IPv4 and IPv6, while also support 5227.

>
> Anyone know any good literature on how the ARP + neigh state machine works
> in the kernel.
>
> I read in Herberts book about the Linux TCP/IP stack and it only discuss how to reply to
> ARP requests and not anything on how to generate ARP requests.

Hope that helps.

--Sowmini
