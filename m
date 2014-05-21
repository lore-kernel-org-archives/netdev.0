From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: cleanup invocation of internal
 BPF
Date: Wed, 21 May 2014 17:07:31 -0400 (EDT)
Message-ID: <20140521.170731.1855118307231797714.davem@davemloft.net>
References: <1400536574-4485-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, edumazet@google.com, keescook@chromium.org,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbaEUVHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 17:07:34 -0400
In-Reply-To: <1400536574-4485-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 19 May 2014 14:56:14 -0700

> Kernel API for classic BPF socket filters is:
> 
> sk_unattached_filter_create() - validate classic BPF, convert, JIT
> SK_RUN_FILTER() - run it
> sk_unattached_filter_destroy() - destroy socket filter
> 
> Cleanup internal BPF kernel API as following:
> 
> sk_filter_select_runtime() - final step of internal BPF creation.
>   Try to JIT internal BPF program, if JIT is not available select interpreter
> SK_RUN_FILTER() - run it
> sk_filter_free() - free internal BPF program
> 
> Disallow direct calls to BPF interpreter. Execution of the BPF program should
> be done with SK_RUN_FILTER() macro.
> 
> Example of internal BPF create, run, destroy:
> 
>   struct sk_filter *fp;
> 
>   fp = kzalloc(sk_filter_size(prog_len), GFP_KERNEL);
>   memcpy(fp->insni, prog, prog_len * sizeof(fp->insni[0]));
>   fp->len = prog_len;
> 
>   sk_filter_select_runtime(fp);
> 
>   SK_RUN_FILTER(fp, ctx);
> 
>   sk_filter_free(fp);
> 
> Sockets, seccomp, testsuite, tracing are using different ways to populate
> sk_filter, so first steps of program creation are not common.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thank you.
