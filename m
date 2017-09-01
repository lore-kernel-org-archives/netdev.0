From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/3] bpf: Inline LRU map lookup
Date: Fri, 01 Sep 2017 11:18:28 +0200
Message-ID: <59A925E4.6060802@iogearbox.net>
References: <20170901062713.1842249-1-kafai@fb.com> <20170901062713.1842249-3-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39236 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdIAJSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 05:18:30 -0400
In-Reply-To: <20170901062713.1842249-3-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 08:27 AM, Martin KaFai Lau wrote:
> Inline the lru map lookup to save the cost in making calls to
> bpf_map_lookup_elem() and htab_lru_map_lookup_elem().
>
> Different LRU hash size is tested.  The benefit diminishes when
> the cache miss starts to dominate in the bigger LRU hash.
> Considering the change is simple, it is still worth to optimize.
>
> First column: Size of the LRU hash
> Second column: Number of lookups/s
>
> Before:
>> for i in $(seq 9 20); do echo "$((2**i+1)): $(./map_perf_test 1024 1 $((2**i+1)) 10000000 | awk '{print $3}')"; done
> 513: 1132020
> 1025: 1056826
> 2049: 1007024
> 4097: 853298
> 8193: 742723
> 16385: 712600
> 32769: 688142
> 65537: 677028
> 131073: 619437
> 262145: 498770
> 524289: 316695
> 1048577: 260038
>
> After:
>> for i in $(seq 9 20); do echo "$((2**i+1)): $(./map_perf_test 1024 1 $((2**i+1)) 10000000 | awk '{print $3}')"; done
> 513: 1221851
> 1025: 1144695
> 2049: 1049902
> 4097: 884460
> 8193: 773731
> 16385: 729673
> 32769: 721989
> 65537: 715530
> 131073: 671665
> 262145: 516987
> 524289: 321125
> 1048577: 260048
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
