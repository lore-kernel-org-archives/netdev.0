From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Mon, 01 Mar 2010 03:29:45 +0100
Message-ID: <1267410585.9082.115.camel@edumazet-laptop>
References: <1267067593.16986.1583.camel@debian>
	 <1267097080.2822.14.camel@edumazet-laptop>
	 <1267151683.16986.1646.camel@debian>
	 <1267189945.2822.1572.camel@edumazet-laptop>
	 <1267409827.23196.44.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shi, Alex" <alex.shi@intel.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:33565 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab0CAC3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 21:29:49 -0500
Received: by bwz1 with SMTP id 1so80245bwz.21
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 18:29:47 -0800 (PST)
In-Reply-To: <1267409827.23196.44.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 mars 2010 =C3=A0 10:17 +0800, Zhu Yi a =C3=A9crit :
> On Fri, 2010-02-26 at 21:12 +0800, Eric Dumazet wrote:
> > Well, if you have one processor, and a process doesnt want to yield
> > the cpu (apart of sofirq of course that is filling the backlog whil=
e
> > your process tries to empty it), your machine is dead. This is
> > critical too :)=20
>=20
> If you only have one CPU, this won't happen. Because while the receiv=
er
> is busy processing the backlog, no senders will have the chance to be
> scheduled to Tx more. And with the limited backlog, it won't take lon=
g
> for the receiver to finish processing all the frames in the backlog.
>=20

You focus on the case you Intel guys discovered the flaw, using loopbac=
k
interface. I am concerned with a DOS situation, when some bad guys on
your LAN sends a flood on your machine, using a real 10Gb NIC.

I was concerned by two things :

- One process being stuck forever in the __release_sock(), basically
stopping an application from performing progress. This is a DOS problem=
=2E
Our kernel is potentially affected. We probably should do something to
avoid this problem. But I am _not_ saying this should be done by your
patch, it is probably possible to address it in an independant patch.

- One process being stuck in __release_sock() and not yield to other
processes. This is not the case since we call the cond_resched_sofirq()
function that permits other high priority task to get the CPU.


One more point :

If you remember my previous mail, I suggested cleaning the len field in
__release_sock(). This way, you can provide a first patch, protocol
agnostic, then provide further patch for UDP V4, another patch for UDP
V6, etc... to have a clean path and make the resolution of the bugs mor=
e
self explaining and not as a whole and big patch.
=20
Thanks


