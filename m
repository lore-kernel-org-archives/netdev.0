From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
Date: Tue, 27 Oct 2015 11:37:21 -0700
Message-ID: <CALx6S37X_+fEH0-_0DZTuGi4VJ6Xk86zi4wSnDiiH_fkUC3sQw@mail.gmail.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
	<1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
	<CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
	<1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
	<CALx6S34m5jEDMUtVZpsU05Z8ydXAYFoVBAsbAQF=sUc5h0TLiQ@mail.gmail.com>
	<1445970551.497935.421785961.521DBDF0@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36093 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326AbbJ0ShW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 14:37:22 -0400
Received: by ioll68 with SMTP id l68so232867952iol.3
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 11:37:21 -0700 (PDT)
In-Reply-To: <1445970551.497935.421785961.521DBDF0@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 11:29 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Tue, Oct 27, 2015, at 18:32, Tom Herbert wrote:
>> On Tue, Oct 27, 2015 at 9:44 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> >
>> >
>> > On Tue, Oct 27, 2015, at 17:36, Tom Herbert wrote:> > -               if
>> > (cork->length + length > maxnonfragsize - headersize) {
>> >> > +       if (cork->length + length > maxnonfragsize - headersize) {
>> >> >  emsgsize:
>> >> > -                       ipv6_local_error(sk, EMSGSIZE, fl6,
>> >> > -                                        mtu - headersize +
>> >> > -                                        sizeof(struct ipv6hdr));
>> >> > -                       return -EMSGSIZE;
>> >> > -               }
>> >> > +               ipv6_local_error(sk, EMSGSIZE, fl6,
>> >> > +                                mtu - headersize +
>> >> > +                                sizeof(struct ipv6hdr));
>> >> > +               return -EMSGSIZE;
>> >> >         }
>> >> >
>> >> > +       /* CHECKSUM_PARTIAL only with no extension headers and when
>> >>
>> >> No, please don't do this. CHECKSUM_PARTIAL should work with extension
>> >> headers as defined, so this is just disabling otherwise valid and
>> >> useful functionality. If (some) drivers have problems with this they
>> >> need to be identified and fixed.
>> >
>> > I don't understand. The old code already didn't allow the use of
>> > opt_flen with CHECKSUM_PARTIAL.
>> >
>> Then that's a problem with the old code :-). Is there any other reason
>> that we can't use CHECKSUM_PARTIAL with extension headers other than
>> lack of correct driver support?
>
> The lack of correct driver support is a big bumper, but as I wrote, I
> don't see a reason to not lift this restriction in net-next. I proposed
> a new feature flag, or by looking at your series, we could probably use
> the extension header okay field for that.
>
Okay, but why bother doing this for net? This problem has obviously
existed for a while, and even if the restriction is maintained here
there are still other paths that don't go through ip_append_data that
could trip the bug. Also, drivers are welcome to fix their issues in
net I believe.

> I would be conservative in net though.
>
> Bye,
> Hannes
