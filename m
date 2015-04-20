From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH 06/10] ipv6: Avoid deleting RTF_CACHE route from
 ip6_route_del()
Date: Mon, 20 Apr 2015 12:33:05 -0700
Message-ID: <20150420193304.GD2416462@devbig242.prn2.facebook.com>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
 <1428717253-1006248-7-git-send-email-kafai@fb.com>
 <20150420.142305.507346652058648202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40529 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750872AbbDTTdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 15:33:12 -0400
Content-Disposition: inline
In-Reply-To: <20150420.142305.507346652058648202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2015 at 02:23:05PM -0400, David Miller wrote:
> From: Martin KaFai Lau <kafai@fb.com>
> Date: Fri, 10 Apr 2015 18:54:09 -0700
> 
> > Before patch 'Allow pmtu update on /128 via gateway route',
> > RTF_CACHE route was not created for DST_HOST.  It also requires changes on both
> > delete code path and rt6_select() code patch.
> > 
> > This patch fixes the delete code path to avoid deleting the RTF_CACHE
> > route by 'ip -6 r del...'
> > 
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> If a cached route was created in response to say a PMTU event, and
> it's a clone/copy/cow of the route we are being asked to delete,
> it absolutely should be removed.
> 
> In fact this is a critically important aspect of removing routes
> from the table.
When a non-clone routes are removed, its clones are removed together by
fib6_prune_clones() in fib6_del().

Hence, 'ip -6 r del' will remove a route and its clones.
'ip -6 r flush table cache will only remove RTF_CACHE routes.

I will fix up the commit message.

Thanks,
--Martin
