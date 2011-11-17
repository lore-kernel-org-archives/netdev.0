From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 11:51:03 +0100
Message-ID: <1321527063.2751.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111117064826.GA4429@Desktop-Junchang>
	 <20111117093635.GA9112@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Junchang Wang <junchangwang@gmail.com>, nic_swsd@realtek.com,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39290 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755511Ab1KQKvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 05:51:08 -0500
Received: by bke11 with SMTP id 11so1804780bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 02:51:06 -0800 (PST)
In-Reply-To: <20111117093635.GA9112@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 10:36 +0100, Francois Romieu a =C3=A9c=
rit :
> Junchang Wang <junchangwang@gmail.com> :
> >=20
> > Switch to use ndo_get_stats64 to get 64bit statistics.
> > Per cpu data is used to avoid lock operations.
>=20
> The 816x chipsets have hardware stats registers. The driver already
> use them. Please use them more.
>=20

I would like to mention a possible bias.

I know for that tg3 includes in RX counters frames/bytes that were
dropped (because napi handler couldnot keep up with the load)

They also include FCS in the byte count.

When using software counters, we can compare "ethtool -S" and "ifconfig=
"
ones.

But generaly speaking, if hardware stats are available we should use
them and save few instructions per packet ;)
