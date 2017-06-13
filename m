From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 01/15] net: BPF support for socket ops
Date: Tue, 13 Jun 2017 17:12:16 -0400 (EDT)
Message-ID: <20170613.171216.2009613899492344910.davem@davemloft.net>
References: <20170613180004.3008403-1-brakmo@fb.com>
        <20170613180004.3008403-2-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752615AbdFMVMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 17:12:18 -0400
In-Reply-To: <20170613180004.3008403-2-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 13 Jun 2017 10:59:50 -0700

> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index a20ba40..8f69b8b 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -899,4 +899,14 @@ static inline int bpf_tell_extensions(void)
>  	return SKF_AD_MAX;
>  }
>  
> +struct bpf_socket_ops_kern {
> +	struct	sock *sk;
> +	__u32	is_req_sock:1;
> +	__u32	op;
> +	union {
> +		__u32 reply;
> +		__u32 replylong[4];
> +	};
> +};
> +
>  #endif /* __LINUX_FILTER_H__ */

In non-UAPI headers, "u32", "u16", "u8", etc. without leading underscores
shoudl be used.
