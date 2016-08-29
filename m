From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFCv2 02/16] net: cls_bpf: add hardware offload
Date: Mon, 29 Aug 2016 16:51:04 +0200
Message-ID: <57C44BD8.2090402@iogearbox.net>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com> <1472234775-29453-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42494 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932884AbcH2OvJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 10:51:09 -0400
In-Reply-To: <1472234775-29453-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2016 08:06 PM, Jakub Kicinski wrote:
> This patch adds hardware offload capability to cls_bpf classifier,
> similar to what have been done with U32 and flower.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

[...]
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index a459be5fe1c2..a86262f0d93a 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -486,4 +486,18 @@ struct tc_cls_matchall_offload {
>   	unsigned long cookie;
>   };
>
> +enum tc_clsbpf_command {
> +	TC_CLSBPF_ADD,
> +	TC_CLSBPF_REPLACE,
> +	TC_CLSBPF_DESTROY,
> +};
> +
> +struct tc_cls_bpf_offload {
> +	enum tc_clsbpf_command command;
> +	struct tcf_exts *exts;
> +	struct bpf_prog *filter;

Small nit: s/filter/prog/, I think prog is a more appropriate name since
it's about more than just filtering. (I will rename it at some point for
cls_bpf as well.)

Rest looks good to me.
