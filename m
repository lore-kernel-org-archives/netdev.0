From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Fri, 26 Feb 2010 14:12:25 +0100
Message-ID: <1267189945.2822.1572.camel@edumazet-laptop>
References: <1267067593.16986.1583.camel@debian>
	 <1267097080.2822.14.camel@edumazet-laptop>
	 <1267151683.16986.1646.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shi, Alex" <alex.shi@intel.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:50697 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936095Ab0BZNMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 08:12:31 -0500
Received: by mail-bw0-f209.google.com with SMTP id 1so51273bwz.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 05:12:30 -0800 (PST)
In-Reply-To: <1267151683.16986.1646.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 f=C3=A9vrier 2010 =C3=A0 10:34 +0800, Zhu Yi a =C3=A9cri=
t :
> On Thu, 2010-02-25 at 19:24 +0800, Eric Dumazet wrote:
> > - What about other protocols that also use a backlog ?
>=20
> I don't think protocols with flow/congestion control capability have
> such issue. We have tested TCP is immune. Other current backlog users
> are dccp, sctp, tipc, x.25 and llc. We didn't test all of them. But
> looks like only llc here is possible but unlikely?
>=20

I looked again for TCP case and I see same problem than UDP. If socket
is locked by user, and a softirq flood happens, you can fill backlog to=
o
with frames (any frame with correct tuple, even with bad sequences), an=
d
exhaust memory.


> > - __release_sock() could run forever with no preemption, even with =
a
> > limit on backlog.=20
>=20
> Yes, but there is no critical impact like memory exhausted for this
> case.
>=20

Well, if you have one processor, and a process doesnt want to yield the
cpu (apart of sofirq of course that is filling the backlog while your
process tries to empty it), your machine is dead. This is critical
too :)



