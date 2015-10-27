From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked
 sockets
Date: Tue, 27 Oct 2015 19:29:11 +0100
Message-ID: <1445970551.497935.421785961.521DBDF0@webmail.messagingengine.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
 <CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
 <1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
 <CALx6S34m5jEDMUtVZpsU05Z8ydXAYFoVBAsbAQF=sUc5h0TLiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:57950 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964840AbbJ0S3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 14:29:14 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 4C3F020280
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 14:29:11 -0400 (EDT)
In-Reply-To: <CALx6S34m5jEDMUtVZpsU05Z8ydXAYFoVBAsbAQF=sUc5h0TLiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015, at 18:32, Tom Herbert wrote:
> On Tue, Oct 27, 2015 at 9:44 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> >
> >
> > On Tue, Oct 27, 2015, at 17:36, Tom Herbert wrote:> > -               if
> > (cork->length + length > maxnonfragsize - headersize) {
> >> > +       if (cork->length + length > maxnonfragsize - headersize) {
> >> >  emsgsize:
> >> > -                       ipv6_local_error(sk, EMSGSIZE, fl6,
> >> > -                                        mtu - headersize +
> >> > -                                        sizeof(struct ipv6hdr));
> >> > -                       return -EMSGSIZE;
> >> > -               }
> >> > +               ipv6_local_error(sk, EMSGSIZE, fl6,
> >> > +                                mtu - headersize +
> >> > +                                sizeof(struct ipv6hdr));
> >> > +               return -EMSGSIZE;
> >> >         }
> >> >
> >> > +       /* CHECKSUM_PARTIAL only with no extension headers and when
> >>
> >> No, please don't do this. CHECKSUM_PARTIAL should work with extension
> >> headers as defined, so this is just disabling otherwise valid and
> >> useful functionality. If (some) drivers have problems with this they
> >> need to be identified and fixed.
> >
> > I don't understand. The old code already didn't allow the use of
> > opt_flen with CHECKSUM_PARTIAL.
> >
> Then that's a problem with the old code :-). Is there any other reason
> that we can't use CHECKSUM_PARTIAL with extension headers other than
> lack of correct driver support?

The lack of correct driver support is a big bumper, but as I wrote, I
don't see a reason to not lift this restriction in net-next. I proposed
a new feature flag, or by looking at your series, we could probably use
the extension header okay field for that.

I would be conservative in net though.

Bye,
Hannes
