From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: fix lockdep issue in __neigh_event_send
Date: Mon, 19 Sep 2011 17:01:54 -0700
Message-ID: <CAHo-Oow0JfWyKmkB+rmY9D3GJvaAwVNuZzrdNA0vuQZ4=i+EGA@mail.gmail.com>
References: <1316459578-23413-1-git-send-email-zenczykowski@gmail.com>
	<1316461375.2455.4.camel@edumazet-laptop>
	<CANP3RGdxYg0Utfyrqfwoj+ojfCD+ZYJTa91nzPSdWBznZWKHaA@mail.gmail.com>
	<1316465182.2455.10.camel@edumazet-laptop>
	<1316466207.2455.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	MuraliRaja Muniraju <muralira@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:54635 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab1ITABz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 20:01:55 -0400
Received: by gwb15 with SMTP id 15so6095895gwb.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 17:01:54 -0700 (PDT)
In-Reply-To: <1316466207.2455.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> To my knowledge, no linux pristine linux kernel has this bug.
>
> dst_release() is lockless.

You are probably right there, I missed that this was caused by some
other old crappy code we've been trying to get rid of.

> So could you explain why its so important we add this 'bugfix' if it
> only applies to a Google kernel ?

Freeing the skb later seemed to be pretty painless...

> Anything I missed from my previous analysis ?
>
> Thanks !

Probably not.
Now that the dst cache is going away this probably doesn't really
matter either way.

Maciej
