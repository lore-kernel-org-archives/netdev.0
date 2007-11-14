From: Ulrich Drepper <drepper@redhat.com>
Subject: network interface state
Date: Wed, 14 Nov 2007 12:59:52 -0800
Message-ID: <473B61C8.3030302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754274AbXKNU77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 15:59:59 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lAEKxwq0017996
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 15:59:58 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lAEKxwHL025234
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 15:59:58 -0500
Received: from myware66.akkadia.org (vpn-15-25.rdu.redhat.com [10.11.15.25])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id lAEKxvnf022685
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 15:59:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Just FYI, with the current getaddrinfo code it is even more critical to
get to a point where I can cache network interface information and quer=
y
the kernel whether it changed.  We now have to read the RTM_GETADDR
tables for every lookup.  It was more limited with the old, incomplete
implementation.

Even if it's something as simple as a RTM_SEQUENCE request which return=
s
a number that is bumped at every interface change.

Related: I need to know about the device type (the ARPHRD_* values) to
determine whether a device is for a native transport or a tunnel.  What
I currently do is:

- - at the beginning I get information about all interfaces using
RTM_GETADDR

- - them later I have to find the device type by

  + reading the RTM_GETLINK data to get to the device name

  + then using the name and ioctl(SIOCGIFHWADDR) I get the device type


It would be so much nicer if the device type would be part of the
RTM_GETADDR data, or at least the RTM_GETLINK data.


Any help on any of these issues?

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHO2HI2ijCOnn/RHQRAtQQAJ0QV6j/BKFmN5nWugrQ/zXf0cCu9wCffRYT
+aXv6y5S1m5iwR7gVfOhp9A=3D
=3DUf3i
-----END PGP SIGNATURE-----
