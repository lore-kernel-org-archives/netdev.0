From: Ulf samuelsson <netdev@emagii.com>
Subject: How to make stack send broadcast ARP request when entry is STALE?
Date: Wed, 5 Nov 2014 07:48:01 +0100
Message-ID: <C4AF677B-55AC-4CE0-9BFB-EBB2E0C3BF74@emagii.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out21.han.skanova.net ([195.67.226.208]:36943 "EHLO
	smtp-out21.han.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750844AbaKEGsL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 01:48:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have a problem with an HP router at a certain location, which
is configured to only answer to broadcast ARP requests.
That cannot be changed.

The first ARP request the kernel sends out, is a broadcast request,
which is fine, but after the reply, the kernel sends unicast requests,
which will not get any replies.

The ARP entry will after some time enter STALE state,
and if nothing is done it will time out, and be removed.
This process takes to long, and I have been told that it is
difficult to makes changes that will eventually remove it.

Have tried to change the state from STALE to INCOMPLETE, which failed,
and then tried to change the state to PROBE which also failed.

The stack is only sending out unicasts, and never broadcast.
Is there any way to get the stack to send out a broadcast ARP
without having to wait for the entry to be removed?

I think the recommended behaviour in IPv6 is to send out 3 unicasts
and if all fails, to send out broadcasts.

Anyone know any good literature on how the ARP + neigh state machine works
in the kernel.

I read in Herberts book about the Linux TCP/IP stack and it only discuss how to reply to 
ARP requests and not anything on how to generate ARP requests.

Best Regards
Ulf Samuelsson
