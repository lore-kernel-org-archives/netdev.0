From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v2 0/4] cgroup: bpf: cgroup2 membership test on skb
Date: Wed, 22 Jun 2016 14:17:28 -0700
Message-ID: <1466630252-3822277-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tejun Heo <tj@kernel.org>, <kernel-team@fb.com>
To: <cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50086 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752184AbcFVVRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 17:17:48 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5MLBjwd007236
	for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 14:17:47 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23qyjv9054-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 14:17:47 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 c375115438be11e6b86724be05956610-495eeaf0 for <netdev@vger.kernel.org>;	Wed,
 22 Jun 2016 14:17:45 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
- Fix two return cases in cgroup_get_from_fd()
- Fix compilation errors when CONFIG_CGROUPS is not used:
  - arraymap.c: avoid registering BPF_MAP_TYPE_CGROUP_ARRAY
  - filter.c: tc_cls_act_func_proto() returns NULL on BPF_FUNC_skb_in_cgroup
- Add comments to BPF_FUNC_skb_in_cgroup and cgroup_get_from_fd()

v1 cover letter:
This series is to implement a bpf-way to
check the cgroup2 membership of a skb (sk_buff).

It is similar to the feature added in netfilter:
c38c4597e4bf ("netfilter: implement xt_cgroup cgroup2 path match")

The current target is the tc-like usage.
