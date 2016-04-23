From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/3] ila: Support for checksum neutral translations
Date: Sat, 23 Apr 2016 11:46:54 -0700
Message-ID: <1461437217-1568717-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41096 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751470AbcDWSrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 14:47:07 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3NIjcrB022855
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 11:47:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22gdvyg3ky-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 11:47:04 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c45399e8098311e6a32a0002c9521c9e-a3bbbc50 for <netdev@vger.kernel.org>;	Sat,
 23 Apr 2016 11:47:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set updates ILA to support draft-herbert-nvo3-ila-02. The
primary addition is support checksum neutral ILA translation.
This allows address to be performed and still keep any transport
layer checksums that include the addresses in their pseudo header to
still be correct without the translator needing to parse L4.

Other items are:
   - Structures for ILA addresses, identifiers, locators
   - Disallow translation on non-ILA addresses (check by
     type in identifier).
   - Change xlat (nf_input) to translates solely based
     on matching locators not identifiers (since identifiers
     are not obfuscated by checksum neutral).
   - Side effect if above is that multiple ILA domains are
     supported. Each local locator can map to a different
     SIR address (ILA domain), and each domain defines its
     own identifier space.

Tested: Ran TCP_RR with 200 cnxs. ILA performance is slightly better
than previously since we are not longer parsing L4 for checksum
handling. I amd seeing about 1% performance overhead. Also ran
TCP_STREAM and tested non-ILA address (type=0) are not translated.

v2: Fix complilation errors

Tom Herbert (3):
  ila: Add struct definitions and helpers
  ila: xlat changes
  ila: add checksum neutral ILA translations

 include/uapi/linux/ila.h  |   7 ++
 net/ipv6/ila/ila.h        |  79 ++++++++++++++++++++++-
 net/ipv6/ila/ila_common.c |  81 +++++++++++++++++++++--
 net/ipv6/ila/ila_lwt.c    |  49 ++++++++++----
 net/ipv6/ila/ila_xlat.c   | 160 +++++++++++++++++++---------------------------
 5 files changed, 259 insertions(+), 117 deletions(-)

-- 
2.8.0.rc2
