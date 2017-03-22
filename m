From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/4] bpf: Fix and simplifications on inline map
 lookup
Date: Wed, 22 Mar 2017 20:33:16 +0100
Message-ID: <58D2D17C.5000508@iogearbox.net>
References: <20170322170035.923581-1-kafai@fb.com> <20170322170035.923581-2-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        FB Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38483 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934729AbdCVTdZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:33:25 -0400
In-Reply-To: <20170322170035.923581-2-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2017 06:00 PM, Martin KaFai Lau wrote:
> Fix in verifier:
> For the same bpf_map_lookup_elem() instruction (i.e. "call 1"),
> a broken case is "a different type of map could be used for the
> same lookup instruction". For example, an array in one case and a
> hashmap in another.  We have to resort to the old dynamic call behavior
> in this case.  The fix is to check for collision on insn_aux->map_ptr.
> If there is collision, don't inline the map lookup.
>
> Please see the "do_reg_lookup()" in test_map_in_map_kern.c in the later
> patch for how-to trigger the above case.
>
> Simplifications on array_map_gen_lookup():
> 1. Calculate elem_size from map->value_size.  It removes the
>     need for 'struct bpf_array' which makes the later map-in-map
>     implementation easier.
> 2. Remove the 'elem_size == 1' test
>
> Fixes: 81ed18ab3098 ("bpf: add helper inlining infra and optimize map_array lookup")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Ok, makes sense (could have been split into two actually).

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
