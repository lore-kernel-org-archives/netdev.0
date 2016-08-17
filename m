From: Tejun Heo <htejun@fb.com>
Subject: Re: [RFC PATCH 4/5] net: filter: run cgroup eBPF programs
Date: Wed, 17 Aug 2016 10:23:36 -0400
Message-ID: <20160817142335.GC4021@htj.duckdns.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-5-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <daniel@iogearbox.net>, <ast@fb.com>, <davem@davemloft.net>,
	<kafai@fb.com>, <fw@strlen.de>, <pablo@netfilter.org>,
	<harald@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57987 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751495AbcHQOYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:24:04 -0400
Content-Disposition: inline
In-Reply-To: <1471442448-1248-5-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 04:00:47PM +0200, Daniel Mack wrote:
> @@ -78,6 +116,12 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
>  	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
>  		return -ENOMEM;
>  
> +#ifdef CONFIG_CGROUP_BPF
> +	err = sk_filter_cgroup_bpf(sk, skb, BPF_ATTACH_TYPE_CGROUP_INGRESS);
> +	if (err)
> +		return err;
> +#endif

Hmm... where does egress hook into?

Thanks.

-- 
tejun
