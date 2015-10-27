From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 2/4] ipv4: add defensive check for CHECKSUM_PARTIAL
 skbs in ip_fragment
Date: Tue, 27 Oct 2015 19:30:43 +0100
Message-ID: <1445970643.498172.421787649.4E2AF4F4@webmail.messagingengine.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-3-git-send-email-hannes@stressinduktion.org>
 <CALx6S35PRhHOtxowWqF4YJYgVMmMiQgn1hf58XXh8QCizY4qcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:54947 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964986AbbJ0Sao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 14:30:44 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id A6286205A1
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 14:30:43 -0400 (EDT)
In-Reply-To: <CALx6S35PRhHOtxowWqF4YJYgVMmMiQgn1hf58XXh8QCizY4qcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015, at 17:06, Tom Herbert wrote:
> On Tue, Oct 27, 2015 at 8:02 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > CHECKSUM_PARTIAL skbs should never arrive in ip_fragment. If we get one
> > of those warn about them once and handle them gracefully by recalculating
> > the checksum.
> >
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Vlad Yasevich <vyasevich@gmail.com>
> > Cc: Benjamin Coddington <bcodding@redhat.com>
> > Cc: Tom Herbert <tom@herbertland.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  net/ipv4/ip_output.c | 8 +++++---
> >  1 file changed, 5 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index 0b02417..3f94a3b 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -533,6 +533,11 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
> >
> >         dev = rt->dst.dev;
> >
> > +       /* for offloaded checksums cleanup checksum before fragmentation */
> > +       if (WARN_ON_ONCE(skb->ip_summed == CHECKSUM_PARTIAL) &&
> > +           (err = skb_checksum_help(skb)))
> > +               goto fail;
> > +
> Why the WARN_ON_ONCE? Is there a prior check somewhere that avoid this
> condition?

While I am pretty sure we should not hit the condition in IPv6 anymore,
I think this could frighten people in IPv4 land. I will repost without
the WARN_ON_ONCE. Maybe it makes sense to use the IFF_DEBUG interface
flags again? :)

I will repost without those WARN_ON_ONCEs.

Bye,
Hannes
