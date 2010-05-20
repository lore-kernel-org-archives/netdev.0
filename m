From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: will 2 cpu simultaneously process packets which have same hash
 value on multiqueue nic?
Date: Thu, 20 May 2010 14:00:26 +0200
Message-ID: <1274356826.4046.29.camel@edumazet-laptop>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497F5B7D6@MILEXCH2.ds.jdsu.net>
	 <1274355967.17395.5.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Zhou <Jon.Zhou@jdsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:42752 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802Ab0ETMAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 08:00:31 -0400
Received: by wwi18 with SMTP id 18so27334wwi.19
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 05:00:29 -0700 (PDT)
In-Reply-To: <1274355967.17395.5.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 mai 2010 =C3=A0 14:46 +0300, Eilon Greenstein a =C3=A9crit =
:
> On Wed, 2010-05-19 at 22:37 -0700, Jon Zhou wrote:
> > will 2 cpu simultaneously  process packets which have same hash val=
ue on multiqueue nic?
> >=20
> > let 's take broadcom 57711 bnx2x_main.c as an example:
> >=20
> > #1 packet1->queue=3D1
> > #2 packet2->queue=3D1
> >=20
> > will cpu1 and cpu2 execute the function " bnx2x_rx_int" in parallel=
, to receive packet1 & packet2
> Both packets will be handled by the same queue and the queue processi=
ng
> is serialized - so the packets will be handled one after the other.

I am scratching my head to understand both the question and your
answer...

if cpu1 is handling an interrupt, cpu2 cannot handle an interrupt at th=
e
same time for same queue. It must be for a different queue.

Therefore, packets will be handled in parallel.

Serialization might be done later, at socket layer to queue packets in =
a
receive queue for example, if both packets must be delivered on same
socket.



