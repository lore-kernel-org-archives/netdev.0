From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 -master 1/2] bpf: update printing of generic xdp
 mode
Date: Sat, 13 May 2017 12:01:44 +0300
Message-ID: <d012ef18-8689-81ef-8f56-ef2b9c673b44@cogentembedded.com>
References: <cover.1494635217.git.daniel@iogearbox.net>
 <3c90a0b9480c61746220636ed48320da53410b6f.1494635217.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34119 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdEMJBr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 13 May 2017 05:01:47 -0400
Received: by mail-lf0-f49.google.com with SMTP id 99so11394881lfu.1
        for <netdev@vger.kernel.org>; Sat, 13 May 2017 02:01:46 -0700 (PDT)
In-Reply-To: <3c90a0b9480c61746220636ed48320da53410b6f.1494635217.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 5/13/2017 3:32 AM, Daniel Borkmann wrote:

> Follow-up to d67b9cd28c1d ("xdp: refine xdp api with regards to
> generic xdp") in order to update the XDP dumping part.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  ip/iplink_xdp.c | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
>
> diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
> index a1380ee..98503fa 100644
> --- a/ip/iplink_xdp.c
> +++ b/ip/iplink_xdp.c
> @@ -79,17 +79,20 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic)
>  void xdp_dump(FILE *fp, struct rtattr *xdp)
>  {
>  	struct rtattr *tb[IFLA_XDP_MAX + 1];
> -	__u32 flags = 0;
> +	__u8 mode;
>
>  	parse_rtattr_nested(tb, IFLA_XDP_MAX, xdp);
>
> -	if (!tb[IFLA_XDP_ATTACHED] ||
> -	    !rta_getattr_u8(tb[IFLA_XDP_ATTACHED]))
> +	if (!tb[IFLA_XDP_ATTACHED])
>  		return;
>
> -	if (tb[IFLA_XDP_FLAGS])
> -		flags = rta_getattr_u32(tb[IFLA_XDP_FLAGS]);
> -
> -	fprintf(fp, "xdp%s ",
> -		flags & XDP_FLAGS_SKB_MODE ? "generic" : "");
> +	mode = rta_getattr_u8(tb[IFLA_XDP_ATTACHED]);
> +	if (mode == XDP_ATTACHED_NONE)
> +		return;
> +	else if (mode == XDP_ATTACHED_DRV)
> +		fprintf(fp, "xdp ");
> +	else if (mode == XDP_ATTACHED_SKB)
> +		fprintf(fp, "xdpgeneric ");
> +	else
> +		fprintf(fp, "xdp[%u] ", mode);

    This is asking to be a *switch* statement.

[...]

MBR, Sergei
