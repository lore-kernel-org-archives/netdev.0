From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: network interface state
Date: Wed, 14 Nov 2007 16:12:28 -0800
Message-ID: <473B8EEC.1010906@redhat.com>
References: <473B61C8.3030302@redhat.com> <20071114.153103.230463871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbXKOAMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 19:12:36 -0500
In-Reply-To: <20071114.153103.230463871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

David Miller wrote:
> Most daemons handle this by listening for events on the netlink
> socket, but I understand how that might not be practical for
> glibc.

Right, this cannot work.  I have no inner loop which I can control.  I
cannot install a listener.

At some point, when we have non-sequential, hidden file descriptors,
I'll be able to leave a socket file descriptor open.  But that's about
it.  Even then the generation counter interface is likely to be the bes=
t
choice.


> It's part of the link information, Look in ifinfomsg->ifi_type

Great, I fixed up the code.  I guess in future, once I can cache the
data, I'll simply read the RTM_GETADDR and RTM_GETLINK data all at once
and be done with it.

BTW, is it possible to send both these requests out before starting to
read the results?  This would reduce the amount of code quite a bit.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHO47s2ijCOnn/RHQRApIIAJwNATDabXkfszG2e+gtJWO9f4wm4wCdFuoQ
Yn40KK+cs9Di4fq+WKTQalo=3D
=3Dq02M
-----END PGP SIGNATURE-----
