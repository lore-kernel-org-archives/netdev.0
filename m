From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 12:44:27 +0200
Message-ID: <1335350667.3274.53.camel@edumazet-glaptop>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	 <1335298228.5205.168.camel@edumazet-glaptop>
	 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	 <1335331960.5205.180.camel@edumazet-glaptop>
	 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
	 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
	 <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
	 <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
	 <CANP3RGf5oTd9mQsXqKj3uXgweMwjs9N3VSeXBHjDXQ7vG0NaSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39466 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756861Ab2DYKod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 06:44:33 -0400
Received: by eaaq12 with SMTP id q12so449185eaa.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 03:44:32 -0700 (PDT)
In-Reply-To: <CANP3RGf5oTd9mQsXqKj3uXgweMwjs9N3VSeXBHjDXQ7vG0NaSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-25 at 03:30 -0700, Maciej =C5=BBenczykowski wrote:

> Hmm, it may be best to honour PMTUs below 1280 to some small but not
> too small value (512?), and below that give up, say mtu remains 1280
> but still add the frag header.
>=20

Thats a good idea.


> (re: Eric's patch, I think it should protect itself against malicious
> PMTU messages with too small MTUs, like 0 or 1 or 68 [not enough for
> timestamped ipv6/tcp)

Yes, in fact we are going to keep the allfrag feature, and arm it if we
receive an mtu < 512.

I'll send a v3 patch soon.

Thanks
