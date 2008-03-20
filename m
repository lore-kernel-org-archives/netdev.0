From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: r8169 driver fails to see IGMPv2 SAP announcements
Date: Thu, 20 Mar 2008 13:48:33 -0700
Message-ID: <OF47F0798E.811EA708-ON88257412.0070C381-88257412.00724DBB@us.ibm.com>
References: <55935F57-5B1B-4F9A-9B37-6236419C6F81@lincor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Glen Gray <glen.gray@lincor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:36019 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbYCTUsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 16:48:37 -0400
In-Reply-To: <55935F57-5B1B-4F9A-9B37-6236419C6F81@lincor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Glen,
        From your detailed description, and particularly the fact
that the problem seems to be tied to the driver & device, I think
I'd recommend looking at the multicast address filter code in the
driver. IGMP is not device dependent, so I doubt that is the
source of the problem.
        If you can reproduce the problem, then while it's
happening:

1) catch the group memberships by saving /proc/net/igmp
2) catch the hardware group memberships by saving
        /proc/net/dev_mcast
[I expect from the symptoms that 1) is ok, 2) may or may not be...]
and...
3) run tcpdump or wireshark in promiscuous mode
        - if the device address filter is the problem, when you
        put the device in promiscuous mode, everything will
        start working again, until you exit tcpdump. You will
        also see the packets you aren't receiving are being
        sent, if that's the problem.

I understand you probably can't directly reproduce it, and
the visual artifacts you mentioned in that one test may or
may not be the same issue as the other one.

Another possibility that comes to mind is a memory leak,
if the response problems are related to a low memory
condition. So, that might be something else to look for.
Compare memory usage with ordinary usage, check
for log messages of allocation failures and check "netstat -s"
output for any indication of drops.

If you can set a program or script to monitor the system
and detect when you hit the problem, then you could use
that to trigger running a script that captures the data you
need when it happens.

                                        +-DLS

