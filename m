From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] ebpf: verifier: check that call reg with
 ARG_ANYTHING is initialized
Date: Thu, 12 Mar 2015 15:29:53 -0400 (EDT)
Message-ID: <20150312.152953.1275852274250204822.davem@redhat.com>
References: <8bb5d2d9c8d471c1161ae60ea92141aef00a4fc8.1426172976.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, challa@noironetworks.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430AbbCLTaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 15:30:13 -0400
In-Reply-To: <8bb5d2d9c8d471c1161ae60ea92141aef00a4fc8.1426172976.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 12 Mar 2015 17:21:42 +0100

> I noticed that a helper function with argument type ARG_ANYTHING does
> not need to have an initialized value (register).
> 
> This can worst case lead to unintented stack memory leakage in future
> helper functions if they are not carefully designed, or unintended
> application behaviour in case the application developer was not careful
> enough to match a correct helper function signature in the API.
> 
> The underlying issue is that ARG_ANYTHING should actually be split
> into two different semantics:
> 
>   1) ARG_DONTCARE for function arguments that the helper function
>      does not care about (in other words: the default for unused
>      function arguments), and
> 
>   2) ARG_ANYTHING that is an argument actually being used by a
>      helper function and *guaranteed* to be an initialized register.
> 
> The current risk is low: ARG_ANYTHING is only used for the 'flags'
> argument (r4) in bpf_map_update_elem() that internally does strict
> checking.
> 
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  I'm fine with this going to net-next, but it also applies to net.

Applied to net-next, thanks Daniel.
