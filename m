From: Saku Ytti <saku@ytti.fi>
Subject: Re: arp_filter and IPv6 ND
Date: Fri, 2 Dec 2016 19:51:00 +0200
Message-ID: <CAAeewD_erNdBw-zjPP9iFuju6FDgAgWrMKhMXPb58nqa0r22rA@mail.gmail.com>
References: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
 <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
 <CAAeewD_2tfNHhWmtwXb_28DicmipReimRvGqv1Q6PQ0AjkBPGw@mail.gmail.com> <cead0544-5a5b-ccd0-e02d-abb44a41c054@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:36556 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755440AbcLBRvh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:51:37 -0500
Received: by mail-ua0-f181.google.com with SMTP id b35so288343043uaa.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 09:51:01 -0800 (PST)
In-Reply-To: <cead0544-5a5b-ccd0-e02d-abb44a41c054@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 December 2016 at 18:45, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

> next-hop-self attribute on your neighbor in that direction? BGP in
> general doesn't lead to ND entry installs, protocols like IS-IS afair
> can short circuit here.

That's the whole problem, Linux does not think of ND or ARP as
interface specific thing, but as global thing. ND and ARP will happily
answer to query from any interface if any other interface has said IP.
I'm not sure why the Loopback ended up in Cisco ND Cache, answer is
either Cisco queried for it or Linux did gratuitous answer. I believe
gratuitous.

> Hmm, I would keep the Loopback announcements out of the BGP.

It's extremely common way to do anycast, but not interesting for the
topic at hand.

> For enterprise and cloud stuff it is certainly very surprising, as some
> isolations don't work as expected. OTOH it is really easy to build up
> home networks and things are more plug and play.

Can you give me practical example when the behaviour is desirable, my
imagination is failing me. I'm not arguing, I just want to understand
it, as I've never had the need myself.
I've never ran into setup which needs it, but cursory googling shows
several people having broken networks because of the behaviour. If it
is needed, I'm sure it's esoteric setup and perhaps saner default
would that extra sysctl config is needed to get this interface
agnostic ARP/ND behaviour.

> Some RFCs require that for some router implementations (CPE), on the
> other hand weak end model in Linux was probably inherited by IPv4. The
> addition of duplicate address detection (which of course only makes
> sense in strong end systems) to IPv6, basically shows that IPv6 is more
> or less designed to be a strong end system model.
>
> Anyway, a patch to suppress ndisc requests on those interfaces will
> probably be accepted.

Grand, not that I feel comfortable writing it. I'd rather see the
whole suppression functionality moved to neighbour.c from being AFI
specific.

-- 
  ++ytti
