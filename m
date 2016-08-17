From: Tejun Heo <htejun@fb.com>
Subject: Re: [RFC PATCH 4/5] net: filter: run cgroup eBPF programs
Date: Wed, 17 Aug 2016 10:58:52 -0400
Message-ID: <20160817145851.GA6299@htj.duckdns.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-5-git-send-email-daniel@zonque.org>
 <20160817142335.GC4021@htj.duckdns.org>
 <d38eb8a1-1b36-b8cf-a60e-266afe4ecc77@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <daniel@iogearbox.net>, <ast@fb.com>, <davem@davemloft.net>,
	<kafai@fb.com>, <fw@strlen.de>, <pablo@netfilter.org>,
	<harald@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45240 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751993AbcHQO70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:59:26 -0400
Content-Disposition: inline
In-Reply-To: <d38eb8a1-1b36-b8cf-a60e-266afe4ecc77@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 04:36:02PM +0200, Daniel Mack wrote:
> On 08/17/2016 04:23 PM, Tejun Heo wrote:
> > On Wed, Aug 17, 2016 at 04:00:47PM +0200, Daniel Mack wrote:
> >> @@ -78,6 +116,12 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
> >>  	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
> >>  		return -ENOMEM;
> >>  
> >> +#ifdef CONFIG_CGROUP_BPF
> >> +	err = sk_filter_cgroup_bpf(sk, skb, BPF_ATTACH_TYPE_CGROUP_INGRESS);
> >> +	if (err)
> >> +		return err;
> >> +#endif
> > 
> > Hmm... where does egress hook into?
> 
> As stated in the cover letter, that's an open question on my list.

lol sorry about that.  :)

-- 
tejun
