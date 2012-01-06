From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 06 Jan 2012 18:25:59 +0100
Message-ID: <1325870759.2911.37.camel@edumazet-laptop>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	 <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325867504.2911.23.camel@edumazet-laptop>
	 <20120106090929.009a78d6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45377 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2AFR0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 12:26:04 -0500
Received: by wgbdr13 with SMTP id dr13so1966110wgb.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 09:26:02 -0800 (PST)
In-Reply-To: <20120106090929.009a78d6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 06 janvier 2012 =C3=A0 09:09 -0800, Stephen Hemminger a =C3=
=A9crit :

> Since SFQ is classful, I don't see what this buys over just putting
> a red qdisc under each SFQ class?
>=20

You meant RED is classful, not SFQ ?

Idea is to use RED on each flow, not on global SFQ, since as you pointe=
d
out, you already can do that right now (and it has no interest)

You can have this right now using QFQ, and for each QFQ class, attach a
RED qdisc, but memory cost and setup time are crazy.

Please note that RED cant perform head mark or drop. (unless we add new
qdisc ops for this)
We can do it from SFQ because we do our proper queue management.
