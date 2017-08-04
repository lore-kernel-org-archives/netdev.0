From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH] net: comment fixes against BPF devmap helper
 calls
Date: Fri, 04 Aug 2017 15:21:34 +0200
Message-ID: <598474DE.9040005@iogearbox.net>
References: <20170804045822.1032.43840.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com
To: John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38353 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdHDNVh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 09:21:37 -0400
In-Reply-To: <20170804045822.1032.43840.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2017 06:58 AM, John Fastabend wrote:
> Update BPF comments to accurately reflect XDP usage.
>
> Fixes: 97f91a7cf04ff ("bpf: add bpf_redirect_map helper routine")
> Reported-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> ---
>   include/uapi/linux/bpf.h |   16 +++++++++++-----
>   1 file changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 1106a8c..1ae061e 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -345,14 +345,20 @@ enum bpf_attach_type {
>    * int bpf_redirect(ifindex, flags)
>    *     redirect to another netdev
>    *     @ifindex: ifindex of the net device
> - *     @flags: bit 0 - if set, redirect to ingress instead of egress
> - *             other bits - reserved
> - *     Return: TC_ACT_REDIRECT
> - * int bpf_redirect_map(key, map, flags)
> + *     @flags:
> + *	  cls_bpf:
> + *          bit 0 - if set, redirect to ingress instead of egress
> + *          other bits - reserved
> + *	  xdp_bpf:
> + *	    all bits - reserved
> + *     Return: cls_bpf: TC_ACT_REDIRECT
> + *	       xdp_bfp: XDP_REDIRECT

We should probably also mention the XDP_ABORTED / TC_ACT_SHOT
on error(/misuse) similarly as below.

> + * int bpf_redirect_map(map, key, flags)
>    *     redirect to endpoint in map
> + *     @map: pointer to dev map
>    *     @key: index in map to lookup
> - *     @map: fd of map to do lookup in
>    *     @flags: --
> + *     Return: XDP_REDIRECT on success or XDP_ABORT on error
>    *
>    * u32 bpf_get_route_realm(skb)
>    *     retrieve a dst's tclassid
>
