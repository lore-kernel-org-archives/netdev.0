From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Thu, 7 Jan 2016 14:35:51 -0800
Message-ID: <1452206155-1492617-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50829 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752707AbcAGWgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 17:36:15 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u07MYxIO015206
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2016 14:36:14 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 209xry0j8s-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 14:36:14 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 0e331960b58f11e582d90002c95209d8-7d3ee1f0 for <netdev@vger.kernel.org>;	Thu,
 07 Jan 2016 14:36:12 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds BPF_MAP_TYPE_PERCPU_HASH map type which allows
percpu value.

BPF + kprobe is very useful in statistics collection.  In particular,
bpf is strong in doing aggregation within the kernel instead of
outputting a lot of raw samples to the userspace.

In some cases, bumping a counter/value of a particular key will have
noticeable impact.  For example, doing statistics collection
on received packets and aggregating them by network
prefix (like /64 in IPv6).  Having a percpu value can help.
