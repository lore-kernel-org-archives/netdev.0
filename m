From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: only update __use and lastusetime once
 per jiffy at most
Date: Sun, 15 Oct 2017 11:19:49 -0700
Message-ID: <20171015181918.ri2gjp2ypdm37pwd@kafai-mbp>
References: <20171013220807.90366-1-tracywwnj@gmail.com>
 <20171014000924.dcfuqxwlalaigqdq@kafai-mbp.dhcp.thefacebook.com>
 <CANn89i+09PB1=J8mXO495iOK4oe4hsnRF=YsOQQJAsnw5ydeoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Wang <weiwan@google.com>, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35470 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750971AbdJOSUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 14:20:01 -0400
Content-Disposition: inline
In-Reply-To: <CANn89i+09PB1=J8mXO495iOK4oe4hsnRF=YsOQQJAsnw5ydeoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 14, 2017 at 12:26:28AM +0000, Eric Dumazet wrote:
> On Fri, Oct 13, 2017 at 5:09 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> > On Fri, Oct 13, 2017 at 10:08:07PM +0000, Wei Wang wrote:
> >> From: Wei Wang <weiwan@google.com>
> >>
> >> In order to not dirty the cacheline too often, we try to only update
> >> dst->__use and dst->lastusetime at most once per jiffy.
> >
> >
> >> As dst->lastusetime is only used by ipv6 garbage collector, it should
> >> be good enough time resolution.
> > Make sense.
> >
> >> And __use is only used in ipv6_route_seq_show() to show how many times a
> >> dst has been used. And as __use is not atomic_t right now, it does not
> >> show the precise number of usage times anyway. So we think it should be
> >> OK to only update it at most once per jiffy.
> > If __use is only bumped HZ number of times per second and we can do ~3Mpps now,
> > would __use be way off?
> 
> It is not used in the kernel, and is not even reported by user space
> (iproute2) currently.
> 
> With the percpu stuff, we never did the sum anyway.
The pcpu_rt currently does not track __use.

> 
> I believe we should be fine by being very lazy on this field.
> 
> If really someones complain, we will see, but insuring ~one update per
> HZ seems fine.
Fair point.  Make sense.
We currently also don't find the ipv6_route proc-file very useful
other than debugging purpose.
