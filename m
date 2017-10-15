From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] ipv6: only update __use and lastusetime once
 per jiffy at most
Date: Sun, 15 Oct 2017 15:01:32 +0200
Message-ID: <1508072492.2847.5.camel@redhat.com>
References: <20171013220807.90366-1-tracywwnj@gmail.com>
         <20171014000924.dcfuqxwlalaigqdq@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>
To: Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38360 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750836AbdJONBf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 09:01:35 -0400
In-Reply-To: <20171014000924.dcfuqxwlalaigqdq@kafai-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-10-13 at 17:09 -0700, Martin KaFai Lau wrote:
> On Fri, Oct 13, 2017 at 10:08:07PM +0000, Wei Wang wrote:
> > From: Wei Wang <weiwan@google.com>
> > 
> > In order to not dirty the cacheline too often, we try to only update
> > dst->__use and dst->lastusetime at most once per jiffy.
> 
> 
> > As dst->lastusetime is only used by ipv6 garbage collector, it should
> > be good enough time resolution.
> 
> Make sense.
> 
> > And __use is only used in ipv6_route_seq_show() to show how many times a
> > dst has been used. And as __use is not atomic_t right now, it does not
> > show the precise number of usage times anyway. So we think it should be
> > OK to only update it at most once per jiffy.
> 
> If __use is only bumped HZ number of times per second and we can do ~3Mpps now,
> would __use be way off?


It would, but even nowaday such value could not be trusted, due to the
cuncurrent non atomic operation used to update it.

This:

https://marc.info/?l=linux-netdev&m=150653252930953&w=2

was an attempt to preserve a more meaningful value for '__use', but it
requires an additional cacheline.

I'm fine with either options.

Paolo
