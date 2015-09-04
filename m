From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH RFC v2 net 4/5] ipv6: Avoid double dst_free
Date: Fri, 4 Sep 2015 16:52:46 -0700
Message-ID: <20150904235246.GA99888@kafai-mba.local>
References: <1441408362-4177515-1-git-send-email-kafai@fb.com>
 <1441408362-4177515-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48524 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760772AbbIDXw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 19:52:58 -0400
Content-Disposition: inline
In-Reply-To: <1441408362-4177515-5-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 04, 2015 at 04:12:41PM -0700, Martin KaFai Lau wrote:
> @@ -1962,6 +1961,9 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
>  	if (rt == net->ipv6.ip6_null_entry) {
>  		err = -ENOENT;
>  		goto out;
> +	} else if (rt->dst.flags & DST_NOCACHE) {
> +		err = -ENOENT;
> +		goto out;
>  	}
These two cases should be merged.
