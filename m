From: Ulf samuelsson <netdev@emagii.com>
Subject: Re: How to make stack send broadcast ARP request when entry is STALE?
Date: Fri, 7 Nov 2014 11:11:11 +0100
Message-ID: <3A67CF46-0BC1-4BAA-818A-0B656C6B46B6@emagii.com>
References: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com> <545C96D6.5020204@hp.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out11.han.skanova.net ([195.67.226.200]:51427 "EHLO
	smtp-out11.han.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751757AbaKGKLQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 05:11:16 -0500
In-Reply-To: <545C96D6.5020204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HP router is configured by a customer, and they intentionally limit replies
to broadcast, and that is how they want it.

In the previous version of the build system, the Interpeak stack was used
and this would in PROBE state send unicast ARP request, and if that failed
send broadcast ARP.

The native linux stack, when in PROBE state sends only unicast until it decides
that it should enter FAILED state.

The 'mcast_probes' variable seems to be totally ignored, except the first  time,
so I do not see why it is there.

Best Regards
Ulf Samuelsson
ulf@emagii.com
+46  (722) 427 437


> 7 nov 2014 kl. 10:54 skrev Brian Haley <brian.haley@hp.com>:
> 
>> On 11/05/2014 07:48 AM, Ulf samuelsson wrote:
>> Have a problem with an HP router at a certain location, which
>> is configured to only answer to broadcast ARP requests.
>> That cannot be changed.
> 
> Sorry to hear about the problem, but my only suggestions would be to try the latest firmware and/or put a call in to support.  I don't happen work in the division that makes routers...
> 
>> The first ARP request the kernel sends out, is a broadcast request,
>> which is fine, but after the reply, the kernel sends unicast requests,
>> which will not get any replies.
> 
> You might be able to hack this by inserting an ebtables rule - check the dnat target section of the man page - don't know the exact syntax but it would probably end in '-j dnat --to-destination ff:ff:ff:ff:ff:ff'
> 
> -Brian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
