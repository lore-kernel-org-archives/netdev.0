From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: Avoid rt6_probe() taking writer lock in
 the fast path
Date: Wed, 22 Jul 2015 11:43:29 -0700
Message-ID: <20150722184328.GB2832181@devbig242.prn2.facebook.com>
References: <1437522680-3515872-1-git-send-email-kafai@fb.com>
 <55AEFBB3.1010503@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36584 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750803AbbGVSng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 14:43:36 -0400
Content-Disposition: inline
In-Reply-To: <55AEFBB3.1010503@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 11:10:59AM +0900, YOSHIFUJI Hideaki wrote:
> You have to take "some" lock when accessing neigh->nud_state
> theoretically.
I don't think read_lock can buy us a lot of extra protection either.
If it has missed the train, the next ip6_pol_route() call will
trigger rt6_probe().  There are other places checking nud_state without
lock also.

Thanks,
--Martin
