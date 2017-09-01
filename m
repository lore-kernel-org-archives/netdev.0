From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 3/3] bpf: Only set node->ref = 1 if it has not
 been set
Date: Fri, 1 Sep 2017 07:22:52 -0700
Message-ID: <376e7393-143b-aca6-4cb5-0d8987bbe8b3@fb.com>
References: <20170901062713.1842249-1-kafai@fb.com>
 <20170901062713.1842249-4-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44285 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751979AbdIAOXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 10:23:10 -0400
In-Reply-To: <20170901062713.1842249-4-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/31/17 11:27 PM, Martin KaFai Lau wrote:
> This patch writes 'node->ref = 1' only if node->ref is 0.
> The number of lookups/s for a ~1M entries LRU map increased by
> ~30% (260097 to 343313).
>
> Other writes on 'node->ref = 0' is not changed.  In those cases, the
> same cache line has to be changed anyway.
>
> First column: Size of the LRU hash
> Second column: Number of lookups/s
>
> Before:
>> echo "$((2**20+1)): $(./map_perf_test 1024 1 $((2**20+1)) 10000000 | awk '{print $3}')"
> 1048577: 260097
>
> After:
>> echo "$((2**20+1)): $(./map_perf_test 1024 1 $((2**20+1)) 10000000 | awk '{print $3}')"
> 1048577: 343313
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
