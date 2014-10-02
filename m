From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC net 0/2] ipv6: Avoid restaring fib6_lookup() for RTF_CACHE hit
Date: Wed, 1 Oct 2014 23:49:06 -0700
Message-ID: <1412232548-29551-1-git-send-email-kafai@fb.com>
References: <1412230168-19901-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kafai@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39091 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750842AbaJBGte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 02:49:34 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s926mgqj031996
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2014 23:49:33 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1prvjh0sc5-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 23:49:33 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 42a2749e4a0011e4a07724be05956610-d89e93e0 for <netdev@vger.kernel.org>;	Wed,
 01 Oct 2014 23:49:30 -0700
In-Reply-To: <1412230168-19901-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to understand why there is a need to restart fib6_lookup() after
getting rt with RTF_CACHE.

I have adapted the davem's udpflood test
(https://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git) to
support IPv6 and here is the result:

#root > time ./udpflood -l 20000000 -c 250 2401:db00:face:face::2

Before:
real    0m33.224s
user    0m2.941s
sys     0m30.232s

After:
real    0m31.517s
user    0m2.938s
sys     0m28.536s
