From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Tue, 13 Mar 2012 22:02:12 -0700
Message-ID: <1331701332.2456.25.camel@edumazet-laptop>
References: <1327570722.8191.46.camel@probook>
	 <1331697865.2456.19.camel@edumazet-laptop>
	 <CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jdb@comx.dk, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:33162 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab2CNFCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 01:02:15 -0400
Received: by yhmm54 with SMTP id m54so1385192yhm.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 22:02:14 -0700 (PDT)
In-Reply-To: <CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 mars 2012 =C3=A0 04:52 +0000, Dave Taht a =C3=A9crit :

> I had some hope for a semi-random alternating queue
>=20

I spent some time implementing two queues, one for new flows, one for
old flows. As soon as a new flow uses its initial quantum, its moved at
the tail of 'old flows queue'.

But I always could find a way to starve some flows, even adding some
kind of persistence. Right now, as soon as we empty one flow, we forget
its history.

Next packet coming will create a "new flow" with a full quantum credit,
even if we nearly consume all flow quantum in the last micro second.

Thats definitely not a trivial problem.
