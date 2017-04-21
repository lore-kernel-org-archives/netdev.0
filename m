From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix values type used in test_maps
Date: Fri, 21 Apr 2017 15:29:27 -0400 (EDT)
Message-ID: <20170421.152927.791898060188963796.davem@davemloft.net>
References: <20170420.152016.2219427430519868937.davem@davemloft.net>
        <58F92725.5050304@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, borkmann@iogearbox.net, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424371AbdDUT3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:29:33 -0400
In-Reply-To: <58F92725.5050304@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 20 Apr 2017 23:24:53 +0200

> On 04/20/2017 09:20 PM, David Miller wrote:
>>
>> Maps of per-cpu type have their value element size adjusted to 8 if it
>> is specified smaller during various map operations.
>>
>> This makes test_maps as a 32-bit binary fail, in fact the kernel
>> writes past the end of the value's array on the user's stack.
>>
>> To be quite honest, I think the kernel should reject creation of a
>> per-cpu map that doesn't have a value size of at least 8 if that's
>> what the kernel is going to silently adjust to later.
> 
> It's unintuitive, agree, and it's in fact a round_up(value_size, 8),
> so rejecting a value size smaller than 8 doesn't really help; commit
> 15a07b33814d ("bpf: add lookup/update support for per-cpu hash and
> array maps") explained the rationale a bit. Hmm, we should probably
> move at least the bpf_num_possible_cpus() and round_up(val_size, 8)
> calculation as a single wrapper function to be used for determining
> the array size into bpf_util.h, so that it's slightly easier to deal
> with.
> 
>> If the user passed something smaller, it is a sizeof() calcualtion
>> based upon the type they will actually use (just like in this testcase
>> code) in later calls to the map operations.
> 
> Fixes: df570f577231 ("samples/bpf: unit test for
> BPF_MAP_TYPE_PERCPU_ARRAY")
> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Ok, applied to net-next, thanks to you and Alexei for reviewing.
