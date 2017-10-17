From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 1/3] ipv6: fix route cache dump
Date: Tue, 17 Oct 2017 21:35:17 +0200
Message-ID: <1508268917.2548.6.camel@redhat.com>
References: <cover.1508261949.git.pabeni@redhat.com>
         <e54ccbb0c97570a8c1a9c97a3c7bc8a910f02083.1508261949.git.pabeni@redhat.com>
         <CAEA6p_DRZA4aHW-Rxb7kJnwhPAy9HqDzY1nQgFGjCwNeVmTfJA@mail.gmail.com>
         <CANn89iK867x7NSoLbDC55CnZg2DHhLc-=pvNQAD3W6hRqiu+Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <edumazet@google.com>, Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57111 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965952AbdJQTfU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 15:35:20 -0400
In-Reply-To: <CANn89iK867x7NSoLbDC55CnZg2DHhLc-=pvNQAD3W6hRqiu+Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 2017-10-17 at 11:41 -0700, Eric Dumazet wrote:
> On Tue, Oct 17, 2017 at 11:26 AM, Wei Wang <weiwan@google.com> wrote:
> > On Tue, Oct 17, 2017 at 10:40 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > > After the commit 2b760fcf5cfb ("ipv6: hook up exception table to
> > > store dst cache"), entries in the routing cache are not shown by:
> > > 
> > > ip route show cache
> > 
> > Hi Paolo,
> > 
> > Thanks for doing this.
> > But I think your patch does not take care of the case where there are
> > a lot of cached routes in the exception table and 1 skb is just not
> > enough to dump the main route + all cached routes in the exception
> > table.
> > In this case, your patch will keep dumping the same main route.
> > 
> > I think some logic needs to be incorporated into the fib6_walk() so
> > that it can also remember the last dumped cached route if necessary in
> > the exception table and start from there for the next dump.
> > I do have a patch for that and that patch tries to keep a linked list
> > of all cached routes from the exception table in the walker struct and
> > remove any routes that are already dumped.
> > It is a bit complicated and might not be the best solution. And as
> > IPv4 already does not support dumping cached routes, I did not send
> > that out in the previous patch series.

Thanks for the feedback.

You are right, I was too hasty with this.

> Yes, since we no longer dump IPV4 cached routes, I doubt anyone
> depends on IPv6 cached routes, but not on IPv4 ones.
> 
> Paolo, do you have a concrete use case for this ?

I have a testing script looking for that, but I guess I can adapt it.

I'm fine with dropping cached routes dumping support if there is
agreement on that.

I haven't understood that such change was intentional.

Cheers,

Paolo
