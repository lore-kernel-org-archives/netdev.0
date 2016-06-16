From: Joe Perches <joe@perches.com>
Subject: rfc: netfilter: Unhide FWINV macro arguments ?
Date: Thu, 16 Jun 2016 11:20:59 -0700
Message-ID: <1466101259.19647.51.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0124.hostedemail.com ([216.40.44.124]:60624 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753256AbcFPSVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 14:21:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several FWINV #defines with identical form
that hide a specific structure variable and dereference
it with a invflags member.

$ git grep "define FWINV"
include/linux/netfilter_bridge/ebtables.h:#define FWINV(bool,invflg) ((bool) ^ !!(info->invflags & invflg))
net/bridge/netfilter/ebtables.c:#define FWINV2(bool, invflg) ((bool) ^ !!(e->invflags & invflg))
net/ipv4/netfilter/arp_tables.c:#define FWINV(bool, invflg) ((bool) ^ !!(arpinfo->invflags & (invflg)))
net/ipv4/netfilter/ip_tables.c:#define FWINV(bool, invflg) ((bool) ^ !!(ipinfo->invflags & (invflg)))
net/ipv6/netfilter/ip6_tables.c:#define FWINV(bool, invflg) ((bool) ^ !!(ip6info->invflags & (invflg)))
net/netfilter/xt_tcpudp.c:#define FWINVTCP(bool, invflg) ((bool) ^ !!(tcpinfo->invflags & (invflg)))

It might make sense to use a new macro like:

#define INVFLAG(var, test, invflag)			\
	((test) ^ !!((var)->invflags & (invflag)))

and convert all the various FWINV style uses

$ git grep --name-only "\bFWINV"
include/linux/netfilter_bridge/ebtables.h
net/bridge/netfilter/ebt_802_3.c
net/bridge/netfilter/ebt_arp.c
net/bridge/netfilter/ebt_ip.c
net/bridge/netfilter/ebt_ip6.c
net/bridge/netfilter/ebt_stp.c
net/bridge/netfilter/ebtables.c
net/ipv4/netfilter/arp_tables.c
net/ipv4/netfilter/ip_tables.c
net/ipv6/netfilter/ip6_tables.c
net/netfilter/xt_tcpudp.c

$ git grep "\bFWINV" | grep -v "#" | wc -l
65
