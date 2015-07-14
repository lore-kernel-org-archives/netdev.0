From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/3] rhashtable: Wildcard and scored lookups
Date: Mon, 13 Jul 2015 17:39:10 -0700
Message-ID: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54598 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752812AbbGNAj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 20:39:29 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6E0dSid029451
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vmpssg5ba-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:28 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 c5a95e8e29c011e58ecb24be05956610-c0da2b0 for <netdev@vger.kernel.org>;	Mon,
 13 Jul 2015 17:39:23 -0700
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


Tom Herbert (3):
  rhashtable: Add a function for in order insertion in buckets
  rhashtable: allow lookup function to have compare function agument
  rhashtable: Add scored lookups

 include/linux/rhashtable.h | 122 ++++++++++++++++++++++++++++++++++++++++++---
 lib/rhashtable.c           |  20 ++++----
 2 files changed, 125 insertions(+), 17 deletions(-)

-- 
1.8.1
