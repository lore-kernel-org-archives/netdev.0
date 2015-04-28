From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/5] ipv6: Stop /128 route from disappearing after pmtu update
Date: Tue, 28 Apr 2015 13:03:02 -0700
Message-ID: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Yang Yingliang <yangyingliang@huawei.com>,
	shengyong <shengyong1@huawei.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55030 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030947AbbD1UDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:03:44 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3SK3BP4029670
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2fn7g9jw-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:44 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 a0db25bcede111e4951c0002c991e86a-6d7f52c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 13:03:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series is separated from another patch series,
'ipv6: Only create RTF_CACHE route after encountering pmtu exception',
which can be found here:
http://thread.gmane.org/gmane.linux.network/359140

This series focus on fixing the /128 route issues.  It is currently targeted
for net-next due to the number of code churn but it is also applicable
to net (should be without conflict).  The original reported problem can be
found here:
http://thread.gmane.org/gmane.linux.network/348138

Patch 01 and 02 are to prepare the fib6 search to expect both the
RTF_CACHE clone and its original route exist at the same fib6_node.

Patch 03 fixes the /128 route disappearing bug.

Patch 04 and 05 stop rt6_info from using the inet_peer's metrics to
avoid the /128 routes (like the /128 clone and its original route)
from stepping on each others' metrics.

The second patch is by 'Steffen Klassert <steffen.klassert@secunet.com>'
which I pulled off from netdev.  The third patch is also mostly by
Steffen with one minor optimization.

Many thanks to Hannes Frederic Sowa <hannes@stressinduktion.org> on
reviewing the patches and giving advice.

--Martin
