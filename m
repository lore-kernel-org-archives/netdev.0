From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/3] bpf: Only set node->ref = 1 if it has not
 been set
Date: Fri, 01 Sep 2017 11:28:15 +0200
Message-ID: <59A9282F.5080906@iogearbox.net>
References: <20170901062713.1842249-1-kafai@fb.com> <20170901062713.1842249-4-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41208 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751755AbdIAJ2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 05:28:16 -0400
In-Reply-To: <20170901062713.1842249-4-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 08:27 AM, Martin KaFai Lau wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
