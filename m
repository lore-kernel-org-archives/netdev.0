From: Ming-Ching Tiew <mingching.tiew@redtone.com>
Subject: Re: [Bugme-new]  [Bug 9719] New: when a system is configured as a
 bridge, and at the same time configured to have multipath weighted route,
 with one leg goes thru NAT and another without NAT, the nat path will intermittently
 get packets leaking out using internal IP without being SNAT-ted
Date: Sun, 13 Jan 2008 09:04:04 +0800
Message-ID: <47896384.3000402@redtone.com>
References: <bug-9719-10286@http.bugzilla.kernel.org/> <20080109152813.83fb8168.akpm@linux-foundation.org> <47863CA8.1010301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.cnx.com.my ([202.46.113.21]:2360 "EHLO mail.cnx.com.my"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756880AbYALL5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 06:57:40 -0500
In-Reply-To: <47863CA8.1010301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andrew Morton wrote:
>>> Distribution: iptables 1.4.0 was used with kernel 2.6.23 and 
>>> iptables 1.3.8
>>> with 2.6.22.15
>>> Hardware Environment: 3 interfaces, 2 interfaces bridged to form 
>>> br0, and
>>> another connects to internet using pppoe.
>>> Software Environment: bridge, multipath routing
>>> Problem Description: when a system is configured as a bridge with IP 
>>> assigned
>>> to br0 interface, and at the same time it is configured to have 
>>> multipath
>>> weighted default route, and one of the default route is NAT-ed and 
>>> another of
>>> the default route is not NAT-ed, then it is NAT-ed interface will 
>>> occasionally
>>> get packets leaking out to it with packets with private IPs.
>
>
> That is most likely because the route changes over time (when the cache
> is flushed) and the NAT mappings for the connection have been set up on
> a different interface. The way to properly do this is to add routing
> rules based on fwmark and use CONNMARK to bind a connection to one of
> the interfaces after the initial multipath routing decision.
>

First of all, I would like to say a big thank you to all of you takes 
interest in replying my post/email. I have altered the distribution 
slightly and the kernel bug list is removed.

It seems from your reply, what is implied is that I cannot change route 
within a connection, and whatever things I do, I must make sure that the 
route remains the same for a particular netfilter connection ?

Regards.


