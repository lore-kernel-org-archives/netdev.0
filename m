From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bpf: no need to nullify ri->map in xdp_do_redirect
Date: Thu, 17 Aug 2017 08:59:52 -0700
Message-ID: <5995BD78.1070808@gmail.com>
References: <782d0b6850cb1a63230c0fd634f1e61d67a01e60.1502975082.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:38485 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751305AbdHQQAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 12:00:03 -0400
Received: by mail-pg0-f66.google.com with SMTP id 123so10506609pga.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 09:00:02 -0700 (PDT)
In-Reply-To: <782d0b6850cb1a63230c0fd634f1e61d67a01e60.1502975082.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 06:07 AM, Daniel Borkmann wrote:
> We are guaranteed to have a NULL ri->map in this branch since
> we test for it earlier, so we don't need to reset it here.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  net/core/filter.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index e9f8dce..ea3ca34 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2568,7 +2568,6 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
>  
>  	fwd = dev_get_by_index_rcu(dev_net(dev), index);
>  	ri->ifindex = 0;
> -	ri->map = NULL;
>  	if (unlikely(!fwd)) {
>  		bpf_warn_invalid_xdp_redirect(index);
>  		return -EINVAL;
> 

Thanks this was on my todo list as well.

Acked-by: John Fastabend <john.fastabend@gmail.com>
