From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 1 Sep 2015 18:02:06 -0700
Message-ID: <20150902010206.GA77629@kafai-mba.local>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
 <1441133703-1570969-4-git-send-email-kafai@fb.com>
 <1441138460.8932.182.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150901205505.GA66075@kafai-mba.local>
 <1441142818.8932.185.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150901222533.GB66075@kafai-mba.local>
 <1441147116.8932.188.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150902003144.GD66075@kafai-mba.local>
 <20150902004200.GA77081@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37775 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751461AbbIBBCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 21:02:16 -0400
Content-Disposition: inline
In-Reply-To: <20150902004200.GA77081@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2015 at 05:42:00PM -0700, Martin KaFai Lau wrote:
> I look a closer look at dst_rcu_free() and your commit pointers.  I can see your point
> for DST_NOCACHE.
>
> However, dst_free() for not DST_NOCACHE is still an issue, I think.
oops. Ignore this email and continue the discussion in my last email instead.

For DST_NOCACHE, dst_release() is doing call_rcu(dst_destroy_rcu)
and dst_destroy_rcu() is directly calling dst_destroy().   I was confused dst_rcu_free()
was used instead.... time for a break towards the end of the day :p
