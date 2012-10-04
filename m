From: Julian Anastasov <ja@ssi.bg>
Subject: IPVS-DR problem with neigh lookup in 3.6
Date: Thu, 4 Oct 2012 09:52:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210040923010.1618@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39725 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755016Ab2JDGrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 02:47:37 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q946qmnq002033
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2012 09:52:49 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

	I suspect commit a263b3093641fb1ec377582c90986a7fd0625184
is causing problem for the IPVS Direct Routing mode which
requests output route for real server IP (RIP) but packets
contain virtual IP (VIP). Before 3.6 ip_finish_output2 used
the neighbour address while now we use iph daddr. The
result is that now we send ARP query for VIP instead of RIP.

	Is it a good idea to keep rt_gateway always
valid and to check RTCF_REDIRECTED where needed?
While checking this option I see that the value of
0 is not good for matching, for example, callforward_do_filter
in net/netfilter/nf_conntrack_h323_main.c will fail
too. If we do such change there is a chance some rt_gateway
checks to disappear, other will be replaced with check for
RTCF_REDIRECTED flag. Should I try such option?
Because adding rt_dst does not look good, it will not
help to callforward_do_filter too.

Regards

--
Julian Anastasov <ja@ssi.bg>
