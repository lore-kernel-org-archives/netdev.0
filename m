From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 0/4] [NET]: Bloat, bloat and more bloat
Date: Sat,  5 Jan 2008 15:39:04 +0200
Message-ID: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47078 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768AbYAENjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 08:39:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

After Arnaldo got codiff's inline instrumentation bugs fixed
(thanks! :-)), I got my .c-inline-bloat-o-meter to power up
reliably after some tweaking and bug fixing on my behalf...
It shows some very high readings every now and then in the
code under net/.

...Aand... we've a sovereign winner, though it was only fifth
on a kernel wide list (arch/ excluded due to number of
reasons) :-/.

Hall of (unquestionable) fame (measured per inline, top 10 under
net/):
  -4496 ctnetlink_parse_tuple        netfilter/nf_conntrack_netlink.c
  -2165 ctnetlink_dump_tuples        netfilter/nf_conntrack_netlink.c
  -2115 __ip_vs_get_out_rt           ipv4/ipvs/ip_vs_xmit.c
  -1924 xfrm_audit_helper_pktinfo    xfrm/xfrm_state.c
  -1799 ctnetlink_parse_tuple_proto  netfilter/nf_conntrack_netlink.c
  -1268 ctnetlink_parse_tuple_ip     netfilter/nf_conntrack_netlink.c
  -1093 ctnetlink_exp_dump_expect    netfilter/nf_conntrack_netlink.c
  -1060 ccid3_update_send_interval   dccp/ccids/ccid3.c
  -983  ctnetlink_dump_tuples_proto  netfilter/nf_conntrack_netlink.c
  -827  ctnetlink_exp_dump_tuple     netfilter/nf_conntrack_netlink.c

Removing inlines is done iteratively because e.g., uninlining
ctnetlink_parse_tuple affected ..._{proto,ip} prices as well.

i386/gcc (GCC) 4.1.2 20070626 (Red Hat 4.1.2-13)/allyesconfig
except CONFIG_FORCED_INLINING. Tried without some CONFIG.*DEBUG
as well and got slightly better numbers for some functions, yet
the number don't differ enough to be that meaningful, ie., if  
there's bloat somewhere, removing DEBUGs won't make it go away.

...After this first aid we're at least below 1k :-).

--
 i.


