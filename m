From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 08/10] bpf: nfp: Report bpf_prog ID during
 XDP_QUERY_PROG
Date: Mon, 12 Jun 2017 18:28:42 -0700
Message-ID: <20170612182842.3150789d@cakuba.netronome.com>
References: <20170613010025.2983342-1-kafai@fb.com>
        <20170613010025.2983342-9-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35480 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752508AbdFMB2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 21:28:46 -0400
Received: by mail-pg0-f52.google.com with SMTP id k71so52576707pgd.2
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 18:28:46 -0700 (PDT)
In-Reply-To: <20170613010025.2983342-9-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jun 2017 18:00:23 -0700, Martin KaFai Lau wrote:
> +	case XDP_QUERY_PROG: {
> +		const struct bpf_prog *xdp_prog;
> +
> +		xdp_prog = READ_ONCE(nn->dp.xdp_prog);
> +		if (xdp_prog)
> +			xdp->prog_id = xdp_prog->aux->id;
> +		else
> +			xdp->prog_id = 0;
>  		return 0;
> +	}
>  	default:
>  		return -EINVAL;
>  	}

Why READ_ONCE?  I thought .ndo_xdp is always called under RTNL.
