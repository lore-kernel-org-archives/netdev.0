From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 0/2] pskb_extract() helper function.
Date: Fri, 22 Apr 2016 18:36:34 -0700
Message-ID: <cover.1461368732.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com, eric.dumazet@gmail.com,
	marcelo.leitner@gmail.com
To: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45119 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbcDWBhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 21:37:11 -0400
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

v2: Marcelo Leitner review comments


Sowmini Varadhan (2):
  Add pskb_extract() helper function
  Call pskb_extract() helper function

 include/linux/skbuff.h |    2 +
 net/core/skbuff.c      |  242 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/tcp_recv.c     |   14 +--
 3 files changed, 247 insertions(+), 11 deletions(-)
