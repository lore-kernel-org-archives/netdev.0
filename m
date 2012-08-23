From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC 0/2] Interface for TCP Metrics
Date: Thu, 23 Aug 2012 18:01:43 +0300
Message-ID: <1345734105-28328-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50889 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755307Ab2HWO74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 10:59:56 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q7NF20Nv028357
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 18:02:00 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q7NF20qg028354
	for netdev@vger.kernel.org; Thu, 23 Aug 2012 18:02:00 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patchset contains 2 patches, one for kernel
and one for iproute2. We add DUMP/GET/DEL support for
genl "tcp_metrics" and minimal support for filtering
by address prefix and family in user space.

	I tested show/del/flush, filtering by family, prefix,
output for metrics such as rtt, rttvar, cwnd, ssthresh (after
modifying route). I didn't tested output for fast open.

	May be some corrections in output can be desired.

	The kernel patch has some parts to check:

- in tcp_metrics_nl_cmd_del I'm trying to flush all addresses
with single request, eg. when no family, address or other
selectors are provided. I use some arbitrary counter sync_count
to force memory to be freed in parts by using synchronize_rcu,
note that we are under genl_mutex, so may be this is bad idea
to delay other genl users? My idea was to avoid many commands
on "flush all", may be we should trigger flush by using some
other mechanism that is pernet? And I don't know how to test
it properly without large cache.

- This function now uses rcu_dereference_protected, someone
should check if these lockdep checks are correct. I enabled
lockdep in config and don't see any warnings.
