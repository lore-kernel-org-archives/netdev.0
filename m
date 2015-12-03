From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/4] qed: Fix corner case for chain in-between pages
Date: Thu, 3 Dec 2015 05:59:13 -0500
Message-ID: <1449140356-17419-2-git-send-email-manish.chopra@qlogic.com>
References: <1449140356-17419-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, Tomer Tayar <Tomer.Tayar@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37787 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756081AbbLCLjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:39:31 -0500
In-Reply-To: <1449140356-17419-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@qlogic.com>

The amount of chain next pointer elements between the producer
and the consumer indices depends on which pages they currently
point to. The current calculation is based only on their difference,
and it can lead to a number of free elements which is higher by 1
than the actual value.

Signed-off-by: Tomer Tayar <Tomer.Tayar@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 include/linux/qed/qed_chain.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/qed/qed_chain.h b/include/linux/qed/qed_chain.h
index b920c36..41b9049 100644
--- a/include/linux/qed/qed_chain.h
+++ b/include/linux/qed/qed_chain.h
@@ -111,7 +111,8 @@ static inline u16 qed_chain_get_elem_left(struct qed_chain *p_chain)
 	used = ((u32)0x10000u + (u32)(p_chain->prod_idx)) -
 		(u32)p_chain->cons_idx;
 	if (p_chain->mode == QED_CHAIN_MODE_NEXT_PTR)
-		used -= (used / p_chain->elem_per_page);
+		used -= p_chain->prod_idx / p_chain->elem_per_page -
+			p_chain->cons_idx / p_chain->elem_per_page;
 
 	return p_chain->capacity - used;
 }
-- 
1.7.1
