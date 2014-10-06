From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 0/5] ipv6: cleanup after rt6_genid removal
Date: Mon,  6 Oct 2014 19:58:33 +0200
Message-ID: <cover.1412618014.git.hannes@stressinduktion.org>
Cc: hideaki@yoshifuji.org, kafai@fb.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53366 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753065AbaJFR6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:58:52 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 39B7220A2B
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 13:58:52 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leftover patches after rt6_genid removal after 705f1c869d577c ("ipv6:
remove rt6i_genid").

Major two changes are:
* keep fib6_sernum per namespace to reduce number of flushes in case
  system has high number of namespaces
* make fn_sernum updates cheaper

v2: Incorporated feedback from Cong Wang, thanks a lot!

Hannes Frederic Sowa (5):
  ipv6: minor fib6 cleanups like type safety, bool conversion, inline
    removal
  ipv6: make rt_sernum atomic and serial number fields ordinary ints
  ipv6: only generate one new serial number per fib mutation
  ipv6: make fib6 serial number per namespace
  ipv6: don't walk node's leaf during serial number update

 include/net/ip6_fib.h    |  20 +++++--
 include/net/netns/ipv6.h |   2 +-
 net/ipv6/af_inet6.c      |   2 +-
 net/ipv6/ip6_fib.c       | 142 ++++++++++++++++++++++++-----------------------
 4 files changed, 91 insertions(+), 75 deletions(-)

-- 
1.9.3
