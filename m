From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
Date: Tue, 27 Oct 2015 10:32:42 -0700
Message-ID: <CALx6S34m5jEDMUtVZpsU05Z8ydXAYFoVBAsbAQF=sUc5h0TLiQ@mail.gmail.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
	<1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
	<CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
	<1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35777 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965416AbbJ0Rcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 13:32:43 -0400
Received: by igbkq10 with SMTP id kq10so88195336igb.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 10:32:43 -0700 (PDT)
In-Reply-To: <1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 9:44 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
>
> On Tue, Oct 27, 2015, at 17:36, Tom Herbert wrote:> > -               if
> (cork->length + length > maxnonfragsize - headersize) {
>> > +       if (cork->length + length > maxnonfragsize - headersize) {
>> >  emsgsize:
>> > -                       ipv6_local_error(sk, EMSGSIZE, fl6,
>> > -                                        mtu - headersize +
>> > -                                        sizeof(struct ipv6hdr));
>> > -                       return -EMSGSIZE;
>> > -               }
>> > +               ipv6_local_error(sk, EMSGSIZE, fl6,
>> > +                                mtu - headersize +
>> > +                                sizeof(struct ipv6hdr));
>> > +               return -EMSGSIZE;
>> >         }
>> >
>> > +       /* CHECKSUM_PARTIAL only with no extension headers and when
>>
>> No, please don't do this. CHECKSUM_PARTIAL should work with extension
>> headers as defined, so this is just disabling otherwise valid and
>> useful functionality. If (some) drivers have problems with this they
>> need to be identified and fixed.
>
> I don't understand. The old code already didn't allow the use of
> opt_flen with CHECKSUM_PARTIAL.
>
Then that's a problem with the old code :-). Is there any other reason
that we can't use CHECKSUM_PARTIAL with extension headers other than
lack of correct driver support?

> The MSG_MORE check has nothing to do with that but only with corking.
>
> Bye,
> Hannes
