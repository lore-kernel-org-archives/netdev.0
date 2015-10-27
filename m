From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked
 sockets
Date: Tue, 27 Oct 2015 17:44:09 +0100
Message-ID: <1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
 <CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:37616 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751829AbbJ0QoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 12:44:25 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id D122B20B6A
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 12:44:09 -0400 (EDT)
In-Reply-To: <CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Oct 27, 2015, at 17:36, Tom Herbert wrote:> > -               if
(cork->length + length > maxnonfragsize - headersize) {
> > +       if (cork->length + length > maxnonfragsize - headersize) {
> >  emsgsize:
> > -                       ipv6_local_error(sk, EMSGSIZE, fl6,
> > -                                        mtu - headersize +
> > -                                        sizeof(struct ipv6hdr));
> > -                       return -EMSGSIZE;
> > -               }
> > +               ipv6_local_error(sk, EMSGSIZE, fl6,
> > +                                mtu - headersize +
> > +                                sizeof(struct ipv6hdr));
> > +               return -EMSGSIZE;
> >         }
> >
> > +       /* CHECKSUM_PARTIAL only with no extension headers and when
> 
> No, please don't do this. CHECKSUM_PARTIAL should work with extension
> headers as defined, so this is just disabling otherwise valid and
> useful functionality. If (some) drivers have problems with this they
> need to be identified and fixed.

I don't understand. The old code already didn't allow the use of
opt_flen with CHECKSUM_PARTIAL.

The MSG_MORE check has nothing to do with that but only with corking.

Bye,
Hannes
