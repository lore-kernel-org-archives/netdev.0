From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/9][NETNS][IPV6] make addrconf and icmp per namespace
Date: Wed, 05 Mar 2008 11:13:08 -0800 (PST)
Message-ID: <20080305.111308.05959072.davem@davemloft.net>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59330
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751145AbYCETNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 14:13:10 -0500
In-Reply-To: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 05 Mar 2008 18:56:49 +0100

> The following patchset makes the different part of ipv6 to take
> into account the namespaces. On top of that, addrconf and icmp
> are now aware how to use the namespaces too. So we can move an
> interface inside the namespace and set ip up to have an ipv6
> address autoconfigured and be able to ping it.
> 
> ndisc will come very soon ... :)

Applied and pushed out to net-2.6.26, thanks.

Can you quickly resolve this turd which got added by
these changes to net/ipv6/addrconf.c?

static void addrconf_net_exit(struct net *net)
{
	struct net_device *dev;

	/*
	 * Remove loopback references from default routing entries
	 */
/* 	in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev); */
/* #ifdef CONFIG_IPV6_MULTIPLE_TABLES */
/* 	in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev); */
/* 	in6_dev_put(net->ipv6.ip6_blk_hole_entry->rt6i_idev); */
/* #endif */

Either turn the code on or remove it.

The upstream tree isn't a place to take "notes" using commented out
code to remind you later about something.

Thanks.

