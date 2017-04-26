From: David Miller <davem@davemloft.net>
Subject: Re: more test_progs...
Date: Wed, 26 Apr 2017 10:55:11 -0400 (EDT)
Message-ID: <20170426.105511.742633353102583622.davem@davemloft.net>
References: <20170425.125217.1962662516948420246.davem@davemloft.net>
        <470871b2-c4c0-ad23-7fda-1a38c2736679@fb.com>
        <590056F2.5010600@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S638183AbdDZOzM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 10:55:12 -0400
In-Reply-To: <590056F2.5010600@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 26 Apr 2017 10:14:42 +0200

> On 04/26/2017 05:42 AM, Alexei Starovoitov wrote:
>> That sucks for sparc, of course. I don't have good suggestions for
>> workaround other than marking tcphdr as packed :(
>>  From code efficiency point of view it still will be faster than
>> LD_ABS insn.
> 
> Plus, ld_abs would also only work on skbs right now, and would
> need JIT support for XDP. But it's also cumbersome to use with
> f.e. IPv6, etc, so should not be encouraged, imo.
> 
> One other option for !HAVE_EFFICIENT_UNALIGNED_ACCESS archs could
> be to provide a bpf_skb_load_bytes() helper equivalent for XDP,
> where you eventually do the memcpy() inside. We could see to inline
> the helper itself to optimize it slightly.

We have to do something that works transparently and always,
regardless of whether HAVE_EFFICIENT_UNALIGNED_ACCESS is in
play or not.

And no, marking objects with __packed is not the answer.

What's happening right now is completely unacceptable.
