From: Christopher Schramm <netdev@shakaweb.org>
Subject: ip_rt_min_pmtu
Date: Tue, 04 Dec 2012 22:04:13 +0100
Message-ID: <50BE654D.2010602@shakaweb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.shakaweb.org ([89.238.65.242]:35081 "EHLO shakaweb.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751807Ab2LDVbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 16:31:37 -0500
Received: from g230078089.adsl.alicedsl.de ([92.230.78.89] helo=[10.25.54.3])
	by shakaweb.org with esmtpa (Exim 4.72)
	(envelope-from <netdev@shakaweb.org>)
	id 1Tfzf9-0000T9-WF
	for netdev@vger.kernel.org; Tue, 04 Dec 2012 22:04:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm looking into an interesting detail of the Linux IPv4 implementation 
I stumbled upon during a University course.

In route.c there's a value ip_rt_min_pmtu, defined as 512 + 20 + 20, 
that tells Linux a minimum PMTU to use, even if e. g. an ICMP message 
tells it to set a smaller one.

Of course, this is not a problem in real world, but not 
standard-compliant, since RFC 791 defines a minimum MTU of 68 for IPv4. 
So I wonder what's the reason for the restriction.

I looked into it and found that it appeared in Linux 2.3.15 with the 
following ID in route.c:

v 1.71 1999/08/20 11:05:58 davem

While it was not present in Linux 2.3.14 with:

v 1.69 1999/06/09 10:11:02 davem

I couldn't find any related discussion or patch on the LKML around that 
dates, so I'm asking you for any hints to find out the reason for 
implementing this lower bound.

What I've found on the LKML is a topic around February 15th, 2001, 
titled "MTU and 2.4.x kernel", where Alexey Kuznetsov points out that 
the handling of "DF on syn frames" is broken for MTUs smaller than 128 
and "Preventing DoSes requires to block pmtu discovery at 576 or at 
least 552".

Does anybody know the actual reason for the change in 2.3.15? I first 
thought it's the common misinterpretation that 576 would be the lower 
bound for MTUs in IPv4, but I wonder why it was put in place as a patch 
years after the IPv4 implementation was already done. There seems to 
have been some clear reason for it. I also wonder why it has never been 
removed up to today if it's really nothing more than a mistake.

Would be great if someone could help me shed some light on this.

Regards
