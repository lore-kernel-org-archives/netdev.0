From: Adam Gundy <arg@cyberscience.com>
Subject: Re: soft lockup with conntrackd / keepalived / VLAN
Date: Tue, 06 Jul 2010 13:56:41 -0600
Message-ID: <4C338A79.10404@cyberscience.com>
References: <4C2E0E0B.8040903@cyberscience.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cliff.us.cyberscience.com ([66.250.49.68]:51339 "EHLO
	mail.us.cyberscience.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab0GFT4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jul 2010 15:56:52 -0400
Received: from hermes.us.cyberscience.com ([172.17.10.11]:33587)
	by mail.us.cyberscience.com with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <arg@cyberscience.com>)
	id 1OWEGC-0003FE-0P
	for netdev@vger.kernel.org; Tue, 06 Jul 2010 13:56:52 -0600
Received: from cheetah.dev.us.cyberscience.com ([172.19.30.21])
	by hermes.us.cyberscience.com with esmtpsa (SSL 3.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <arg@cyberscience.com>)
	id 1OWEG1-0004iB-UG
	for netdev@vger.kernel.org; Tue, 06 Jul 2010 13:56:51 -0600
In-Reply-To: <4C2E0E0B.8040903@cyberscience.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adam Gundy wrote:
> I've built a pair of router boxes which are using keepalived and 
> conntrackd to provide a redundant router setup. we're also using a 
> single 802.1Q VLAN on the box.
> 
> occasionally, the box will lockup for 5 minutes, during which time 
> routed traffic is extremely delayed (2 or 3 second ping times). 
> initially, there were no log messages about the lockup. we switched from 
> using an internal nvidia (forcedeth) NIC in the belief that it may have 
> been causing the problem.. however: with the new gigabit NICs, we still 
> see the hangs, but we also get this in the kernel log:

> PS: this is a Ubuntu Lucid kernel - 2.6.32. I'm working on a stock 
> kernel to see if it still happens..

the issue appears to be IPSEC. pings across an IPSEC tunnel get slower and 
slower until the 'five minute fit', then ALL pings (IPSEC or not), plus the 
machine itself are extremely slow or non-responsive.

this behavior is also visible with a stock 2.6.32.15 kernel, but not 
reproducible with 2.6.33.5.

it looks like there were some IPSEC locking changes between those two kernels, 
but I couldn't find any obvious bug reports with similar symptoms..

