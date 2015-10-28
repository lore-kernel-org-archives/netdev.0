From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked
 sockets
Date: Wed, 28 Oct 2015 01:12:30 +0100
Message-ID: <1445991150.565234.422057353.69DCA015@webmail.messagingengine.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
 <CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
 <1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
 <CALx6S34m5jEDMUtVZpsU05Z8ydXAYFoVBAsbAQF=sUc5h0TLiQ@mail.gmail.com>
 <1445970551.497935.421785961.521DBDF0@webmail.messagingengine.com>
 <CALx6S37X_+fEH0-_0DZTuGi4VJ6Xk86zi4wSnDiiH_fkUC3sQw@mail.gmail.com>
 <1445973550.508206.421832305.2B25EDF1@webmail.messagingengine.com>
 <1445982165.537052.421960617.70351761@webmail.messagingengine.com>
 <CALx6S37F236V6YxMhHGbZNCsXxHTTfeXpAXj99GMyA3hnyH5XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46945 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbbJ1AMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 20:12:31 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 95D4620491
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 20:12:30 -0400 (EDT)
In-Reply-To: <CALx6S37F236V6YxMhHGbZNCsXxHTTfeXpAXj99GMyA3hnyH5XA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015, at 23:03, Tom Herbert wrote:
> On Tue, Oct 27, 2015 at 2:42 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > I posted v3 just now. I would like to let David consider it for net
> > inclusion. We can work on how to lift this limitation then in net-next,
> > okay? I am currently in favor of a new netdev-feature. What do you
> > think? Your RFC series could help here, too.
> >
> I really do not like the feature flag, it's just a bandaid over the
> real problem-- in fact my goal is to eliminate NETIF_F_IP{V6}_CSUM and
> just have NETIF_F_HW_CSUM. I will repost the helper patches, but we
> really do need to start fixing this stuff in the drivers instead of
> more hacking in the stack.

It would be great if this is doable but I doubt so. There might be a lot
of unresponsive driver maintainers and I don't see that we should simply
eliminate IPv4 csum offloading for those drivers, too. Sometimes it is
hard to patch drivers without documentation.

I am against lifting restrictions which will have unforeseeable 
consequences for some people (as in partial communication errors) or
having huge performance drawbacks (as in disabling ipv4 csum offloading,
too).

I could even imagine this needs to be more configurable as in how many
extension headers some hardware can process, I fear. One extension
header might be okay (jumping over a fragmentation header), but two... I
simply don't know, yet. Maybe there is no problem with hardware at all.

I don't really see this series as a hack. ;)

Unluckily it seems we don't get feedback from the hardware about not
being able to construct a proper checksum, so we cannot even close the
loop and add code which warns us about misbehaving drivers.

Bye,
Hannes
