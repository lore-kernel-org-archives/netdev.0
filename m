From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next 0/2] pskb_extract() helper function.
Date: Mon, 18 Apr 2016 06:21:07 -0700
Message-ID: <cover.1460928360.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com
To: eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19863 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbcDRNV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 09:21:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset follows up on the discussion in
 https://www.mail-archive.com/netdev@vger.kernel.org/msg105090.html

For RDS-TCP, we have to deal with the full gamut of
nonlinear sk_buffs, including all the frag_list variants.
Also, the parent skb has to remain unchanged, while the clone
is queued for Rx on the PF_RDS socket. 

Patch 1 of this patchset adds a pskb_extract() function that 
does all this without the redundant memcpy's in pskb_expand_head() 
and __pskb_pull_tail().

A further optimization is also possible by inlining pskb_trim()
itself into pskb_carve() and thus avoiding the needless copy
of trailer frags/pages that will then get trimmed away.  I am
deferring that optimization  for the next iteration, and would
like to get feedback on this first pass, which by itself gives
a noticeable perf boost.

Sowmini Varadhan (2):
  Add pskb_extract() helper function
  Call pskb_extract() helper function

 include/linux/skbuff.h |    2 +
 net/core/skbuff.c      |  248 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/tcp_recv.c     |   14 +--
 3 files changed, 253 insertions(+), 11 deletions(-)
