From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: only update __use and lastusetime once
 per jiffy at most
Date: Fri, 13 Oct 2017 17:09:24 -0700
Message-ID: <20171014000924.dcfuqxwlalaigqdq@kafai-mbp.dhcp.thefacebook.com>
References: <20171013220807.90366-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46312 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753089AbdJNAJc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 20:09:32 -0400
Content-Disposition: inline
In-Reply-To: <20171013220807.90366-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 10:08:07PM +0000, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> In order to not dirty the cacheline too often, we try to only update
> dst->__use and dst->lastusetime at most once per jiffy.


> As dst->lastusetime is only used by ipv6 garbage collector, it should
> be good enough time resolution.
Make sense.

> And __use is only used in ipv6_route_seq_show() to show how many times a
> dst has been used. And as __use is not atomic_t right now, it does not
> show the precise number of usage times anyway. So we think it should be
> OK to only update it at most once per jiffy.
If __use is only bumped HZ number of times per second and we can do ~3Mpps now,
would __use be way off?
