From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/3] rhashtable: Wildcard and scored lookups
Date: Tue, 14 Jul 2015 16:45:46 -0700
Message-ID: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>,
	<herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44188 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752577AbbGNXp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 19:45:59 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6ENjvIG003130
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:45:59 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vnaqpr87e-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:45:59 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 79501aec2a8211e5a5c10002c99293a0-1e0bd6b0 for <netdev@vger.kernel.org>;	Tue,
 14 Jul 2015 16:45:57 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set implements:
  - A compare function can be passed in the lookup. This allows for
    comparison to include "wildcard fields"
  - Order insertion within a bucket, so that entries with more specific
    information can be matched first.
  - Scored lookups. This is like the socket lookups. It allows
    different levels of matching, and returning one of N possible
    best matches with a uniform distribution based on flow hash.

Testing: Tested this in conjunction with ILA development. Will be
posting ILA patches shortly.

V2:
 - Added rhashtable_lookup_ordered_cmpfn to ensure that greatest
   ordered matching entry is found during rehashing
 - Minor cleanup to scored lookup patch

Tom Herbert (3):
  rhashtable: Allow lookup function to have compare function agument
  rhashtable: Add a function for in order insertion and lookup in
    buckets
  rhashtable: Add scored lookups

 include/linux/rhashtable.h | 194 +++++++++++++++++++++++++++++++++++++++++++--
 lib/rhashtable.c           |  20 ++---
 2 files changed, 196 insertions(+), 18 deletions(-)

-- 
1.8.1
