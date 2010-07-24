From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] pktgen: Optionally leak kernel memory
Date: Sat, 24 Jul 2010 16:13:15 +0200
Message-ID: <1279980795.2451.157.camel@edumazet-laptop>
References: <4C4A224B.8080806@candelatech.com>
	 <1279949024.2451.43.camel@edumazet-laptop>
	 <4C4AE80F.1040406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:62922 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699Ab0GXONV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 10:13:21 -0400
Received: by wwf26 with SMTP id 26so1550773wwf.1
        for <netdev@vger.kernel.org>; Sat, 24 Jul 2010 07:13:20 -0700 (PDT)
In-Reply-To: <4C4AE80F.1040406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 24 juillet 2010 =C3=A0 06:18 -0700, Ben Greear a =C3=A9crit :

> I think most users of pktgen wouldn't be too concerned about leaking
> memory content to the network.  It's a root-only test tool that can e=
asily
> saturate most networks and do horrible things like overflow switch CA=
M tables
> by randomizing source/dest macs etc.  So, this warning might could be=
 a bit
> more descriptive of how it is a security problem "arbitrary contents =
of memory can be
> sent across the network and may be sniffed by devices on the network,=
 potentially
> revealing private information such as passwords and application data =
for applications
> running on the machine running pktgen" instead of telling folks not t=
o use it unless it's
> really needed.

Most of the horrible things you mention are not related to the memset()
thing, arent they ?


Being root means : "I am a trusted user on this machine, and as such,
must know a bit what security means".

It doesnt mean : "I am allowed to steal passwords, credit card numbers,
from gentle users. I am allowed to blow up the LAN with billions of evi=
l
frames". Still, pktgen is there and might be used by a fool.

The "UNSAFE" label should be more than enough to warn the fool admin ;)

Note this "UNSAFE" thing is really bad. Nowhere in the kernel we are
allowed to make this sort of thing : No special mmap() flag asking
kernel to give non cleared memory pages, even to root user.

I am not sure David will accept the patch !

Anyway, as I said, if you want to saturate a 10Gb+ network with pktgen,
you probably need clone_skb ?



