From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 22:12:35 +0100
Message-ID: <1289423555.17691.8.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop>
	 <1289423056.2249.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61991 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475Ab0KJVMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 16:12:39 -0500
Received: by eye27 with SMTP id 27so717147eye.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 13:12:38 -0800 (PST)
In-Reply-To: <1289423056.2249.7.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 21:04 +0000, Ben Hutchings a =C3=A9=
crit :

> Drivers should calculate differences and accumulate them in a 64-bit
> counter.  (A lot of hardware has read-to-clear counters anyway, in wh=
ich
> case the driver *has* to accumulate the values it reads.)

You are mistaken. These are _hardware_ counters. If they were software,
of course they would be 32 or 64 bit.

And doing the thing you describe in software is racy.
I tried to remove many races, not to add new ones.

Yes, some drivers read one hardware counter using two instructions, and
this is racy.



