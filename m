From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] pskb_extract() helper function.
Date: Wed, 20 Apr 2016 03:17:40 -0700
Message-ID: <cover.1461086306.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com, eric.dumazet@gmail.com,
	marcelo.leitner@gmail.com
To: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36881 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932979AbcDTKS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 06:18:28 -0400
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

Sowmini Varadhan (2):
  Add pskb_extract() helper function
  Call pskb_extract() helper function

 include/linux/skbuff.h |    2 +
 net/core/skbuff.c      |  248 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/tcp_recv.c     |   14 +--
 3 files changed, 253 insertions(+), 11 deletions(-)
