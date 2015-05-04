From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 3/5] ipv6: Stop /128 route from disappearing
 after pmtu update
Date: Sun, 3 May 2015 17:29:38 -0700
Message-ID: <20150504002938.GG2731450@devbig242.prn2.facebook.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
 <1430251387-2942539-4-git-send-email-kafai@fb.com>
 <m2d22itxe2.wl@sfc.wide.ad.jp>
 <20150502232040.GB2731450@devbig242.prn2.facebook.com>
 <m2bni2tsv0.wl@sfc.wide.ad.jp>
 <20150503033801.GE2731450@devbig242.prn2.facebook.com>
 <m27fspu42k.wl@sfc.wide.ad.jp>
 <20150503190108.GF2731450@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<yangyingliang@huawei.com>, <shengyong1@huawei.com>,
	<Kernel-team@fb.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57981 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750969AbbEDAaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 20:30:01 -0400
Content-Disposition: inline
In-Reply-To: <20150503190108.GF2731450@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hajime,

On Sun, May 03, 2015 at 12:01:09PM -0700, Martin KaFai Lau wrote:
> Thanks for the details and confirming the last patch.  I think I may
> know what could be wrong.  I am going to confirm it first by trying
> to reproduce it.
I tried the sit and also the gre6 tunnel.  I cannot make it break as
the way you have observed.  The ping can still go through.  I am probably
missing something.

However, I did uncover a problem in this patch and posted a fix to
netdev.  I have also attached here.  Can you give it a try?

If there is still no luck, do you have a chance to
reproduce it with a simple setup by iproute2 commands?
Can you specify which POINTTOPOINT device and sim device you are using?
Are they in or out of kernel-tree driver?

Thanks,
--Martin

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3522711..106dbe5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -920,7 +920,7 @@ redo_rt6_select:

 	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
-	else if (!(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
+	else if (!(rt->dst.flags & DST_HOST) || !(rt->rt6i_flags & RTF_LOCAL))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
 	else
 		goto out2;
