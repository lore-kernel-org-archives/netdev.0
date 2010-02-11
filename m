From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 3/3] net: reserve ports for applications
 using fixed port numbers
Date: Thu, 11 Feb 2010 07:12:48 +0100
Message-ID: <1265868768.3061.15.camel@edumazet-laptop>
References: <201002110453.35242.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53842 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab0BKGMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 01:12:52 -0500
Received: by bwz19 with SMTP id 19so41694bwz.28
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 22:12:50 -0800 (PST)
In-Reply-To: <201002110453.35242.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian, please resubmit all patches to lkml, netdev, David, because
patches 1 & 2 are changing kernel core services.

However, I'll take some time in a couple of hours to review them.

Le jeudi 11 f=C3=A9vrier 2010 =C3=A0 04:53 +0200, Octavian Purdila a =C3=
=A9crit :
> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports
> (bitmap type) which allows users to reserve ports for third-party
> applications.
>=20
> The reserved ports will not be used by automatic port assignments
> (e.g. when calling connect() or bind() with port number 0). Explicit
> port allocation behavior is unchanged.


> =20
> +extern unsigned long sysctl_local_reserved_ports[65536/8/sizeof(unsi=
gned long)];

I am sure we have a special macro for this.

extern DECLARE_BITMAP(reserved_ports, 65536);

> +unsigned long sysctl_local_reserved_ports[65536/BITS_PER_LONG];
> +

Same point here, plus I am not sure adding 8192 bytes in BSS zone is a
problem nowadays. (It was ten years ago for some arches)



