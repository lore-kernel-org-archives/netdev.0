From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Thu, 23 Aug 2012 13:40:15 +0200
Message-ID: <1345722015.5904.675.camel@edumazet-glaptop>
References: <1344559958-29162-1-git-send-email-brutus@google.com>
	 <50360C81.6000009@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Bruce \"Brutus\" Curtis" <brutus@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65092 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041Ab2HWLkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 07:40:21 -0400
Received: by bkwj10 with SMTP id j10so191658bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 04:40:19 -0700 (PDT)
In-Reply-To: <50360C81.6000009@draigBrady.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 11:57 +0100, P=C3=A1draig Brady wrote:

> Just to quantify the loopback testing compat issue.
> I often do stuff like the following to test latency.
> Will that be impacted?
>=20
>   tc qdisc add dev lo root handle 1:0 netem delay 20msec
>=20

Yes this will. At least for tcp traffic this wont "work".

TCP friends bypass layers, by directly queuing skbs to sockets.

-> no iptables,=20
   no qdisc (by default there is no qdisc on lo),
   no loopback stats (ifconfig lo).
   some SNMP stats missing as well (netstat -s)

> As for the stated tcpdump change,
> I don't suppose it would be possible to dynamically
> disable this (for new connections at least)
> while lo is being dumped?

This could be done, but it might be better to let the admin globally
enable/disable TCP friends...
