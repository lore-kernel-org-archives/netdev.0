From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 0/9][NETNS][IPV6] make addrconf and icmp per namespace
Date: Wed, 05 Mar 2008 20:55:08 +0100
Message-ID: <47CEFA9C.3000800@fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com> <20080305.111308.05959072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:13182 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbYCETzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 14:55:18 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m25JtHLO082124
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:55:17 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25JtGrv1954046
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 20:55:16 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25JtGZt029734
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:55:16 GMT
In-Reply-To: <20080305.111308.05959072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Wed, 05 Mar 2008 18:56:49 +0100
> 
>> The following patchset makes the different part of ipv6 to take
>> into account the namespaces. On top of that, addrconf and icmp
>> are now aware how to use the namespaces too. So we can move an
>> interface inside the namespace and set ip up to have an ipv6
>> address autoconfigured and be able to ping it.
>>
>> ndisc will come very soon ... :)
> 
> Applied and pushed out to net-2.6.26, thanks.
> 
> Can you quickly resolve this turd which got added by
> these changes to net/ipv6/addrconf.c?
> 
> static void addrconf_net_exit(struct net *net)
> {
> 	struct net_device *dev;
> 
> 	/*
> 	 * Remove loopback references from default routing entries
> 	 */
> /* 	in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev); */
> /* #ifdef CONFIG_IPV6_MULTIPLE_TABLES */
> /* 	in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev); */
> /* 	in6_dev_put(net->ipv6.ip6_blk_hole_entry->rt6i_idev); */
> /* #endif */
> 
> Either turn the code on or remove it.
> 
> The upstream tree isn't a place to take "notes" using commented out
> code to remind you later about something.

Oops, sorry. I forgot to remove this comment. I will remove it asap.
