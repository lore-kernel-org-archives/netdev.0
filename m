From: Glen Gray <glen.gray@lincor.com>
Subject: Re: r8169 driver fails to see IGMPv2 SAP announcements
Date: Fri, 21 Mar 2008 08:37:16 +0000
Message-ID: <1081E95E-EE8B-4476-894F-52F21CBB6095@lincor.com>
References: <OF47F0798E.811EA708-ON88257412.0070C381-88257412.00724DBB@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:3729 "EHLO
	scmp07.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750712AbYCUIjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 04:39:33 -0400
In-Reply-To: <OF47F0798E.811EA708-ON88257412.0070C381-88257412.00724DBB@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David,

Some good suggestions there, I'll check those out next week when I'm  
back in the office.
--
Glen Gray <glen.gray@lincor.com>         Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682

On 20 Mar 2008, at 20:48, David Stevens wrote:
> Hi, Glen,
>        From your detailed description, and particularly the fact
> that the problem seems to be tied to the driver & device, I think
> I'd recommend looking at the multicast address filter code in the
> driver. IGMP is not device dependent, so I doubt that is the
> source of the problem.
>        If you can reproduce the problem, then while it's
> happening:
>
> 1) catch the group memberships by saving /proc/net/igmp
> 2) catch the hardware group memberships by saving
>        /proc/net/dev_mcast
> [I expect from the symptoms that 1) is ok, 2) may or may not be...]
> and...
> 3) run tcpdump or wireshark in promiscuous mode
>        - if the device address filter is the problem, when you
>        put the device in promiscuous mode, everything will
>        start working again, until you exit tcpdump. You will
>        also see the packets you aren't receiving are being
>        sent, if that's the problem.
>
> I understand you probably can't directly reproduce it, and
> the visual artifacts you mentioned in that one test may or
> may not be the same issue as the other one.
>
> Another possibility that comes to mind is a memory leak,
> if the response problems are related to a low memory
> condition. So, that might be something else to look for.
> Compare memory usage with ordinary usage, check
> for log messages of allocation failures and check "netstat -s"
> output for any indication of drops.
>
> If you can set a program or script to monitor the system
> and detect when you hit the problem, then you could use
> that to trigger running a script that captures the data you
> need when it happens.
>
>                                        +-DLS
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

