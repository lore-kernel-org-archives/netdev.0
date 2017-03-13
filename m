From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: improve read-only handling
Date: Sun, 12 Mar 2017 23:51:51 -0700 (PDT)
Message-ID: <20170312.235151.1369356708706057105.davem@davemloft.net>
References: <19a5c15f39cec7e0e8eeba8e2add5db859a6d34a.1489246970.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750799AbdCMGvz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:51:55 -0400
In-Reply-To: <19a5c15f39cec7e0e8eeba8e2add5db859a6d34a.1489246970.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 11 Mar 2017 16:55:49 +0100

> Improve bpf_{prog,jit_binary}_{un,}lock_ro() by throwing a
> one-time warning in case of an error when the image couldn't
> be set read-only, and also mark struct bpf_prog as locked when
> bpf_prog_lock_ro() was called.
> 
> Reason for the latter is that bpf_prog_unlock_ro() is called from
> various places including error paths, and we shouldn't mess with
> page attributes when really not needed.
> 
> For bpf_jit_binary_unlock_ro() this is not needed as jited flag
> implicitly indicates this, thus for archs with ARCH_HAS_SET_MEMORY
> we're guaranteed to have a previously locked image. Overall, this
> should also help us to identify any further potential issues with
> set_memory_*() helpers.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  ( My preference is on -net, so we can potentially find and fix
>    any remaining unexpected issue with set_memory_*(). Thanks! )

Ok, applied to -net, thanks Daniel.
