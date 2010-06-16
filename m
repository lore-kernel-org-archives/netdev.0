From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16216] New: wrong source addr of UDP packets
 when using policy routing
Date: Wed, 16 Jun 2010 19:28:29 +0200
Message-ID: <1276709309.2632.126.camel@edumazet-laptop>
References: <bug-16216-10286@https.bugzilla.kernel.org/>
	 <20100616093328.0671254b.akpm@linux-foundation.org>
	 <4C18FFDC.8060102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, borg@uu3.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:42226 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759292Ab0FPRe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 13:34:26 -0400
Received: by wwb18 with SMTP id 18so5898440wwb.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 10:34:24 -0700 (PDT)
In-Reply-To: <4C18FFDC.8060102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 juin 2010 =C3=A0 18:46 +0200, Patrick McHardy a =C3=A9cr=
it :

> This is know behaviour, fwmarks don't work for source address selecti=
on
> since before the source address is chosen, you don't even have a pack=
et
> which could be marked.

We know have sk->sk_mark routing (socket based), so we might change
sk->sk_mark with appropriate iptables target when one packet is
received... not very clean but worth to mention...

commit 914a9ab386a288d0f22252fc268ecbc048cdcbd5
Author: Atis Elsts <atis@mikrotik.com>
Date:   Thu Oct 1 15:16:49 2009 -0700

    net: Use sk_mark for routing lookup in more places
   =20
    This patch against v2.6.31 adds support for route lookup using sk_m=
ark in some
    more places. The benefits from this patch are the following.
    First, SO_MARK option now has effect on UDP sockets too.
    Second, ip_queue_xmit() and inet_sk_rebuild_header() could fail to =
do routing
    lookup correctly if TCP sockets with SO_MARK were used.
   =20
    Signed-off-by: Atis Elsts <atis@mikrotik.com>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


