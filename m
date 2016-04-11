From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: simplify verifier register state
 assignments
Date: Sun, 10 Apr 2016 22:43:56 -0400 (EDT)
Message-ID: <20160410.224356.1432777173706360517.davem@davemloft.net>
References: <1459996761-2926623-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbcDKCoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 22:44:09 -0400
In-Reply-To: <1459996761-2926623-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 6 Apr 2016 19:39:21 -0700

> verifier is using the following structure to track the state of registers:
> struct reg_state {
>     enum bpf_reg_type type;
>     union {
>         int imm;
>         struct bpf_map *map_ptr;
>     };
> };
> and later on in states_equal() does memcmp(&old->regs[i], &cur->regs[i],..)
> to find equivalent states.
> Throughout the code of verifier there are assignements to 'imm' and 'map_ptr'
> fields and it's not obvious that most of the assignments into 'imm' don't
> need to clear extra 4 bytes (like mark_reg_unknown_value() does) to make sure
> that memcmp doesn't go over junk left from 'map_ptr' assignment.
> 
> Simplify the code by converting 'int' into 'long'
> 
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
