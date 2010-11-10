From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 19:18:40 +0100
Message-ID: <1289413120.2469.12.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36799 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab0KJSSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:18:46 -0500
Received: by wyb36 with SMTP id 36so974460wyb.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 10:18:45 -0800 (PST)
In-Reply-To: <4CDADC17.6070506@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 09:53 -0800, Ben Greear a =C3=A9cri=
t :

> I agree, but if these can be read from user-space, it can be tricky t=
o make
> solid code to deal with wraps when the thing wrapping can be 32 or 64=
 bits,
> depending on whether the kernel is compiled 32-bit or 64-bit.
>=20
> So, my preference is to use u32 or u64 so there is no guesswork invol=
ved.
>=20
> To be sure, this problem exists in lots of places already (/proc/net/=
dev comes to mind),
> but the fewer places the better in my opinion.
>=20

On a 32bit kernel, very few devices provide 64bit counters, so an
application reading /proc/net/dev should be prepared to handle 32 or
64bit counter.

On a 64bit kernel, many devices still provide 32, 36, 40 bit counters
(hardware based). Same conclusion for userspace.

So really, an SNMP application must be able to cope with any counter
width.

As percpu data is going to hurt in the 4096 cpu cases, we should try to
not make percpu structures too big.



