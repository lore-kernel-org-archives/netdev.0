From: Loganaden Velvindron <loganaden@gmail.com>
Subject: Re: Fwd: RFC 6980 on Security Implications of IPv6 Fragmentation with
 IPv6 Neighbor Discovery
Date: Thu, 15 Aug 2013 14:14:46 +0400
Message-ID: <CAOp4FwRx3c3deHXupWg3S0aWe4ZJnCT9ORKCWRvUUuxxt1gneQ@mail.gmail.com>
References: <20130813221321.AEA1AB1E003@rfc-editor.org>
	<520B3D81.9070506@gont.com.ar>
	<20130814230617.GA13066@order.stressinduktion.org>
	<520C7519.1010000@gont.com.ar>
	<20130815100407.GA18564@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Fernando Gont <fernando@gont.com.ar>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:51145 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab3HOKOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 06:14:47 -0400
Received: by mail-oa0-f46.google.com with SMTP id l10so591994oag.19
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 03:14:46 -0700 (PDT)
In-Reply-To: <20130815100407.GA18564@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 2:04 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> On Thu, Aug 15, 2013 at 03:28:41AM -0300, Fernando Gont wrote:
> > Thanks so much for your timely response! -- Please find my comments
> > in-line...
> >
> > On 08/14/2013 08:06 PM, Hannes Frederic Sowa wrote:
> > > On Wed, Aug 14, 2013 at 05:19:13AM -0300, Fernando Gont wrote:
> > >> Folks,
> > >>
> > >> FYI. -- this is an important piece when it comes to First Hop (i.e.,
> > >> "local link") Security.
> > >
> > > Thanks for the heads-up, Fernando!
> > >
> > > I sketched up a patch to protect the receiving side. I still don't know if I
> > > should make this behaviour default or configurable via a sysctl knob. I really
> > > don't want to break existing installations.
> >
> > Make it the default behavior. If anything, provide a sysctl knob to
> > override it.
> >
> > Note: In the specific case of NS/NA messages, it's impossible nowadays
> > to find them fragmented in a real network (we don't even have options
> > (other than padding) to make NS/NAs grow so large!).
>
> Yes, I also do favour making this the default behavior.
>
> > > As an extra plus, we now discard packets with nested fragment headers at once.
> > > Those packets should never have been accepted.
> >
> > Is that the "goto fail_hdr" part in your patch?
>
> Yes, still have to check if I should silently ignore them or generate a
> parameter problem (that is the current behavior).
>

I'm not sure if you got my previous mails, but I'd like to know a
couple of things:

1) How can I test this diff ?

2) It's developed against which git brach ? linux-next ?

3) What will/could break with this diff in a production environment ?


> >
> > P.S.: What about RS/RA messages?
>
>
> ndisc_rcv, which does now silently discard fragmented packets, is called
> for the following types:
>
>         case NDISC_ROUTER_SOLICITATION:
>         case NDISC_ROUTER_ADVERTISEMENT:
>         case NDISC_NEIGHBOUR_SOLICITATION:
>         case NDISC_NEIGHBOUR_ADVERTISEMENT:
>         case NDISC_REDIRECT:
>
> So all packet types from RFC6980 should be covered (we do not support SEND,
> yet).
>
> Thanks,
>
>   Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




-- 
This message is strictly personal and the opinions expressed do not
represent those of my employers, either past or present.
