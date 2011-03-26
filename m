From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] socket: add minimum listen queue length sysctl
Date: Sat, 26 Mar 2011 08:06:09 +0100
Message-ID: <1301123169.2979.4.camel@edumazet-laptop>
References: <1301077899-16482-1-git-send-email-hagen@jauu.net>
	 <1301077899-16482-2-git-send-email-hagen@jauu.net>
	 <1301084677.13505.26.camel@tardy>  <20110325235101.GA2641@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64121 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab1CZHGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 03:06:14 -0400
Received: by wya21 with SMTP id 21so1629669wya.19
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2011 00:06:13 -0700 (PDT)
In-Reply-To: <20110325235101.GA2641@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 26 mars 2011 =C3=A0 00:51 +0100, Hagen Paul Pfeifer a =C3=A9c=
rit :

> IMHO, _if_ a programmer modifies the send or receive buffer he _knows=
_ exactly
> why. If he does not modify the buffer it is fine too, because _we_ tu=
ne the
> buffers as good as we can - and we are good in this.
>=20
> But, the backlog is different. Often the programmer does _not_ know h=
ow to
> tune this variable. And, often the backlog depends on the target syst=
em, on
> the network characteristic and the like.
>=20
> Therefore we provide the system administrator the _ability_ to tune t=
he actual
> backlog.

What you want to tune is not the backlog (max number of ready to be
delivered connections to accept()), but the number of SYN_RECV half
connections, still waiting for a second packet coming from clients.

An application might really want to have a listen(fd, 1) to accept one
incoming connection, but still be able to survive to a SYNFLOOD.

By the way, you still are confused by the fact that tcp_max_syn_backlog
has nothing to do with the 'backlog', as I already mentioned it, its a
parameter to cap the size of the hash table associated to a listener
socket.

You can have a hash table with 1024 slots, and still have a backlog of
16384 for example.




