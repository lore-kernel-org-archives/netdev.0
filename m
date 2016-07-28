From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: ip=dhcp woes
Date: Thu, 28 Jul 2016 13:26:13 +0200
Message-ID: <20160728112613.n72e6pein3b5lm4b@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48886 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756838AbcG1L0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 07:26:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a machine with four network interfaces and I'm using ip=3Ddhcp
during development on it.

in ic_dynamic the procedure is the following (assuming no successful
reply is received in time):

  timeout =3D 2s + random([0, 1]) s
loop:
  send bootp on 1st dev
  wait 1s
  send bootp on 2nd dev
  wait 1s
  send bootp on 3rd dev
  wait 1s
  send bootp on 4th dev
  wait timeout
  timeout =3D timeout * 4 / 7
  goto loop;

My problem now is: The dhcp server is reachable via the first device an=
d
takes little more than 1s to respond. A reply must match the last sent
request to be accepted.

So the obvious questions are:

Why is only the last timeout increased for each loop? Why is there a
difference at all between the waits which results in a special casing o=
f
the last device?

Alternatively, why not accept a reply on eth0 when eth1 has already sen=
t
a request? Then the procedure could be:

  timeout =3D 2s + random([0, 1]) s
loop:
  send bootp on 1st dev
  send bootp on 2nd dev
  send bootp on 3rd dev
  send bootp on 4th dev
  wait timeout
  timeout =3D timeout * 4 / 7
  goto loop;

which looks more effective.

Is there anything I missed?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
