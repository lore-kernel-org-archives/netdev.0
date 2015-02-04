From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] pkt_sched: fq: avoid artificial bursts
 for clocked flows
Date: Wed, 04 Feb 2015 10:47:34 -0800
Message-ID: <1423075654.31870.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422992932-9893-1-git-send-email-kennetkl@ifi.uio.no>
	 <1423001164.907.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <2E34EE83-0F64-4CDE-BDE2-4AB59B4D5CF8@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:56274 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161466AbbBDSrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 13:47:36 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so20576378igd.4
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 10:47:35 -0800 (PST)
In-Reply-To: <2E34EE83-0F64-4CDE-BDE2-4AB59B4D5CF8@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 17:56 +0000, Kenneth Klette Jonassen wrote:

>=20
> If it is a code issue, please refactor it or point out some specifics=
=2E
>=20
> Thanks for cc=E2=80=99ing me on your related patch (=E2=80=9Cdo not p=
ace pure ack
> packets=E2=80=9D). Note that your patch does not address the core iss=
ue that
> this patch attempts to fix: fq throttling is just broken for small,
> clocked flows. This not only concerns TCP/SCTP/ARQ acks, but also
> thin-streams like VoIP and gaming.


I already told you this patch was not wanted.

We want a reasonably efficient packet scheduler, allowing TCP pacing,
at the scale of million of flows.

You can reduce quantum to whatever you need.

We have an internal patch doing something really different,
not adding 8 bytes overhead in the flow structure.

We will upstream it when fully tested.

commit 799735e5d08b3a7fc19176eee316ca647c9bad32
Author: Eric Dumazet <edumazet@google.com>
Date:   Mon Aug 11 14:35:36 2014 -0700

    net-sched-fq: special case low rate flows
   =20
    Effort: net-sched-fq
    Change-Id: Ibee17453702cccf729154f6b4db7aeb028fc555a
