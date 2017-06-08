From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/5] bpf: rewrite value tracking in
 verifier
Date: Thu, 08 Jun 2017 16:18:51 -0400 (EDT)
Message-ID: <20170608.161851.611860605114539498.davem@davemloft.net>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, iovisor-dev@lists.iovisor.org,
        linux-kernel@vger.kernel.org
To: ecree@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 7 Jun 2017 15:55:57 +0100

> This series simplifies alignment tracking, generalises bounds tracking and
>  fixes some bounds-tracking bugs in the BPF verifier.  Pointer arithmetic on
>  packet pointers, stack pointers, map value pointers and context pointers has
>  been unified, and bounds on these pointers are only checked when the pointer
>  is dereferenced.
> Operations on pointers which destroy all relation to the original pointer
>  (such as multiplies and shifts) are disallowed if !env->allow_ptr_leaks,
>  otherwise they convert the pointer to an unknown scalar and feed it to the
>  normal scalar arithmetic handling.
> Pointer types have been unified with the corresponding adjusted-pointer types
>  where those existed (e.g. PTR_TO_MAP_VALUE[_ADJ] or FRAME_PTR vs
>  PTR_TO_STACK); similarly, CONST_IMM and UNKNOWN_VALUE have been unified into
>  SCALAR_VALUE.
> Pointer types (except CONST_PTR_TO_MAP, PTR_TO_MAP_VALUE_OR_NULL and
>  PTR_TO_PACKET_END, which do not allow arithmetic) have a 'fixed offset' and
>  a 'variable offset'; the former is used when e.g. adding an immediate or a
>  known-constant register, as long as it does not overflow.  Otherwise the
>  latter is used, and any operation creating a new variable offset creates a
>  new 'id' (and, for PTR_TO_PACKET, clears the 'range').
> SCALAR_VALUEs use the 'variable offset' fields to track the range of possible
>  values; the 'fixed offset' should never be set on a scalar.
> 
> Patch 2/5 is rather on the big side, but since it changes the contents and
>  semantics of a fairly central data structure, I'm not really sure how to go
>  about splitting it up further without producing broken intermediate states.
> 
> With the changes in patch 5/5, all tools/testing/selftests/bpf/test_verifier
>  tests pass.

Edward, I haven't had a chance to review this yet, but I wanted to thank you
for working on this.

I will find some time to test your work on sparc too.

Thanks again!
