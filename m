From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: improve verifier packet range checks
Date: Fri, 24 Mar 2017 20:51:51 -0700 (PDT)
Message-ID: <20170324.205151.2161184203383142347.davem@davemloft.net>
References: <20170324225733.2776121-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, kafai@fb.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966059AbdCYDvx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 23:51:53 -0400
In-Reply-To: <20170324225733.2776121-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 24 Mar 2017 15:57:33 -0700

> llvm can optimize the 'if (ptr > data_end)' checks to be in the order
> slightly different than the original C code which will confuse verifier.
> Like:
> if (ptr + 16 > data_end)
>   return TC_ACT_SHOT;
> // may be followed by
> if (ptr + 14 > data_end)
>   return TC_ACT_SHOT;
> while llvm can see that 'ptr' is valid for all 16 bytes,
> the verifier could not.
> Fix verifier logic to account for such case and add a test.
> 
> Reported-by: Huapeng Zhou <hzhou@fb.com>
> Fixes: 969bf05eb3ce ("bpf: direct packet access")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Martin KaFai Lau <kafai@fb.com>

Applied and queued up for -stable, thanks.
