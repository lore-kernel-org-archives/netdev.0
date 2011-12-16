From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 16:41:20 +0100
Message-ID: <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61631 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043Ab1LPPlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 10:41:24 -0500
Received: by wgbdr13 with SMTP id dr13so6423755wgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 07:41:23 -0800 (PST)
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 16:25 +0100, igorm@etf.rs a =C3=
=A9crit :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Hi all,
> in this patch series I introduced per interface statistics for ipv4.
>=20
> I referenced how it was done for ipv6 per interface statistics.
> BR
> Igor

Questions/Comments are :

1) Why is it needed ? Any RFC requires this bloat ?

2) Every patch in a patch serie must be compilable. Think about
bisection. This is mandatory.

  You cannot have a patch that change prototypes, like your 06/10=20
-#define ICMP_INC_STATS(net, field)     SNMP_INC_STATS((net)->mib.icmp_=
statistics, field)
+#define ICMP_INC_STATS(net, dev, field)        \

 Then, in another patch, 'fix' callers, like your 10/10

-               IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPK=
TS);
+               IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INTRUNCA=
TEDPKTS);
