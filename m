From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3 net] xfrm: move xfrm_garbage_collect out of
 xfrm_policy_flush
Date: Mon, 12 Jun 2017 14:13:42 +0200
Message-ID: <20170612121342.GY2631@secunet.com>
References: <1497013755-24481-1-git-send-email-liuhangbin@gmail.com>
 <1497145460-24614-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
        Xin Long <lucien.xin@gmail.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45684 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751942AbdFLMNp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 08:13:45 -0400
Content-Disposition: inline
In-Reply-To: <1497145460-24614-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 11, 2017 at 09:44:20AM +0800, Hangbin Liu wrote:
> Now we will force to do garbage collection if any policy removed in
> xfrm_policy_flush(). But during xfrm_net_exit(). We call flow_cache_fini()
> first and set set fc->percpu to NULL. Then after we call xfrm_policy_fini()
> -> frxm_policy_flush() -> flow_cache_flush(), we will get NULL pointer
> dereference when check percpu_empty. The code path looks like:
> 
> flow_cache_fini()
>   - fc->percpu = NULL
> xfrm_policy_fini()
>   - xfrm_policy_flush()
>     - xfrm_garbage_collect()
>       - flow_cache_flush()
>         - flow_cache_percpu_empty()
> 	  - fcp = per_cpu_ptr(fc->percpu, cpu)
> 
> To reproduce, just add ipsec in netns and then remove the netns.
> 
> v2:
> As Xin Long suggested, since only two other places need to call it. move
> xfrm_garbage_collect() outside xfrm_policy_flush().
> 
> v3:
> Fix subject mismatch after v2 fix.
> 
> Fixes: 35db06912189 ("xfrm: do the garbage collection after flushing policy")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Patch applied, thanks eveyone!
