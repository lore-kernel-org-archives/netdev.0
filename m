From: Tejun Heo <htejun@fb.com>
Subject: Re: [RFC PATCH 2/5] cgroup: add bpf_{e,in}gress pointers
Date: Wed, 17 Aug 2016 10:10:33 -0400
Message-ID: <20160817141032.GA4021@htj.duckdns.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-3-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <daniel@iogearbox.net>, <ast@fb.com>, <davem@davemloft.net>,
	<kafai@fb.com>, <fw@strlen.de>, <pablo@netfilter.org>,
	<harald@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52418 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752728AbcHQOLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:11:15 -0400
Content-Disposition: inline
In-Reply-To: <1471442448-1248-3-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Aug 17, 2016 at 04:00:45PM +0200, Daniel Mack wrote:
> @@ -5461,6 +5462,14 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
>  	for_each_css(css, ssid, cgrp)
>  		kill_css(css);
>  
> +#ifdef CONFIG_CGROUP_BPF
> +	if (cgrp->bpf_ingress)
> +		bpf_prog_put(cgrp->bpf_ingress);
> +
> +	if (cgrp->bpf_egress)
> +		bpf_prog_put(cgrp->bpf_egress);
> +#endif

This most likely isn't the right place as there still can be sockets
associated with the cgroup and packets flowing.  The cgroup release
path in css_release_work_fn() probably is the right place.

Thanks.

-- 
tejun
