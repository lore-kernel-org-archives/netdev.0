From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 1 Sep 2015 13:55:05 -0700
Message-ID: <20150901205505.GA66075@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55691 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752487AbbIAUz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 16:55:28 -0400
Content-Disposition: inline
In-Reply-To: <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 01:14:20PM -0700, Eric Dumazet wrote:
> It should not be a problem. refcnt is taken when/if necessary (skb
> queued on a qdisc for example)
>
> We have other uses of skb_dst_set_noref()
>
> Please describe the problem ?
The current ip6_tnl_dst_get() does not take the dst refcnt.

If the dst is released after ip6_tnl_dst_get() and before
skb_dst_set_noref(), would it cause an issue?
