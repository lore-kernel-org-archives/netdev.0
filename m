From: Ulrich Drepper <drepper@redhat.com>
Subject: bind and O_NONBLOCK
Date: Thu, 20 Sep 2007 22:59:53 -0700
Message-ID: <46F35DD9.4000909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>, Alan Cox <alan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbXIUGAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 02:00:01 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8L601bY008745
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 02:00:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Some time back Alan asked about adding O_NONBLOCK support to bind in th=
e
POSIX spec.  I brought this up and the following text will be in the
next revision of the POSIX spec:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
If the socket address cannot be assigned immediately and O_NONBLOCK is
set for the file descriptor for the socket, bind( ) shall fail and set
errno to [EINPROGRESS], but the assignment request shall not be aborted=
,
and the assignment shall be completed asynchronously. Subsequent calls
to bind() for the same socket, before the assignment is completed, shal=
l
fail and set errno to [EALREADY].

When the assignment has been performed asynchronously, pselect(),
select(), and poll() shall indicate that the file descriptor for the
socket is ready for reading and writing.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

It would be ideal if we'd have such an implementation in the next few
months so that we, in theory, can check whether the text in the
specification makes sense.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFG813Z2ijCOnn/RHQRAsNkAJ9EuDWX3EDez8+o/y3I39A7Axy++ACfZAXi
DRFm1UadrbJ+c7ss0a1vWUI=3D
=3Dp1bV
-----END PGP SIGNATURE-----
