From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 0/2] bpf: Fix bpf_redirect to an ipip/ip6tnl dev
Date: Wed, 9 Nov 2016 15:36:32 -0800
Message-ID: <1478734594-337666-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34341 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751599AbcKIXhC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:37:02 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA9NYlKY021558
        for <netdev@vger.kernel.org>; Wed, 9 Nov 2016 15:37:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26mc9ngnsb-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 15:37:02 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 696c2050a6d511e6bd1e24be0593f280-275faa50 for <netdev@vger.kernel.org>;        Wed,
 09 Nov 2016 15:37:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set fixes a bug in bpf_redirect(dev, flags) when dev is an
ipip/ip6tnl.  The current problem is IP-EthHdr-IP is sent out instead of
IP-IP.

Patch 1 adds a dev->type test similar to dev_is_mac_header_xmit()
in act_mirred.c which is only available in net-next.  We can consider to
refactor it once this patch is pulled into net-next from net.

Thanks,
-- Martin
