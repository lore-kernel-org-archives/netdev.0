From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC net 0/2] ipv6: Avoid restarting fib6_lookup() for RTF_CACHE hit
Date: Fri, 3 Oct 2014 15:12:10 -0700
Message-ID: <1412374332-26657-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:8355 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757525AbaJCWMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:12:19 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s93LvrHA028173
	for <netdev@vger.kernel.org>; Fri, 3 Oct 2014 15:12:19 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1psys6rye8-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:12:19 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 562fe15e4b4a11e4b21f0002c99331b0-eded3e0 for <netdev@vger.kernel.org>;	Fri,
 03 Oct 2014 15:12:17 -0700
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
