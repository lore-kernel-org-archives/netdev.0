From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH 7/9] AF_UNIX: Documentation on multicast Unix Sockets
Date: Mon, 22 Nov 2010 21:07:40 +0200
Message-ID: <201011222107.41548.remi@remlab.net>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk> <1290450982-17480-7-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:51674 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280Ab0KVTHo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 14:07:44 -0500
In-Reply-To: <1290450982-17480-7-git-send-email-alban.crequy@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 novembre 2010 20:36:20 Alban Crequy, vous avez =E9crit :
> +Multicast Unix sockets
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Multicast group memberships are stored in struct unix_mcast nodes. A=
n Unix
> +socket can join several multicast groups. Struct unix_mcast nodes ar=
e
> doubly +linked:
> +- In (struct unix_sock)->mcast_subscriptions
> +- In (struct unix_sock)->mcast_members

I may be stupid, but I found this whole documentation very confusing, a=
nd so=20
the API it tries to describe. Traditionally:
- Senders may or not may be part of the group and are not kept track of=
=2E
- Receivers join to the group then receive message sent to it.
- Loopback defines whether a sender receives its own echo if it sends t=
o a
group that it has joined.
- If connected to a multicast group, messages from the socket are route=
d to=20
the group (in absence of a contradictoy socket address). This has no ef=
fect on=20
membership to the multicast group under any circumstance.

You cannot 'listen' or 'accept' on a multicast group.

So I am not entirely clear what semantics your patchset is following. B=
ut it=20
does not seem like "multicast" to me and therefore seems not very well=20
documented :-(

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
http://fi.linkedin.com/in/remidenis
