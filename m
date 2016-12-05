From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Preserve const register type on const OR
 alu ops
Date: Mon, 05 Dec 2016 13:41:08 -0500 (EST)
Message-ID: <20161205.134108.1458706052974202517.davem@davemloft.net>
References: <1480797093-1050393-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, g.borello@gmail.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48000 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbcLESuy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:50:54 -0500
In-Reply-To: <1480797093-1050393-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 3 Dec 2016 12:31:33 -0800

> From: Gianluca Borello <g.borello@gmail.com>
> 
> Occasionally, clang (e.g. version 3.8.1) translates a sum between two
> constant operands using a BPF_OR instead of a BPF_ADD. The verifier is
> currently not handling this scenario, and the destination register type
> becomes UNKNOWN_VALUE even if it's still storing a constant. As a result,
> the destination register cannot be used as argument to a helper function
> expecting a ARG_CONST_STACK_*, limiting some use cases.
> 
> Modify the verifier to handle this case, and add a few tests to make sure
> all combinations are supported, and stack boundaries are still verified
> even with BPF_OR.
> 
> Signed-off-by: Gianluca Borello <g.borello@gmail.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, but...

> diff --git a/tools/testing/selftests/bpf/.gitignore b/tools/testing/selftests/bpf/.gitignore
> index 3c59f96e3ed8..071431bedde8 100644
> --- a/tools/testing/selftests/bpf/.gitignore
> +++ b/tools/testing/selftests/bpf/.gitignore
> @@ -1,2 +1,3 @@
>  test_verifier
>  test_maps
> +test_lru_map

This had nothing to do with this change, nor was it mentioned in the
commit message.

Please do not do this in the future.
