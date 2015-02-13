From: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
Subject: VLAN creation may lead to deadlock.
Date: Fri, 13 Feb 2015 13:02:17 +0100
Message-ID: <20150213120217.GA6198@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:47772 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbbBMMDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2015 07:03:06 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YMExF-0002g3-V1
	for netdev@vger.kernel.org; Fri, 13 Feb 2015 13:02:42 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YMEwr-00024U-9I
	for netdev@vger.kernel.org; Fri, 13 Feb 2015 13:02:17 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I stumbled upon the following annoying situation: supposing eth0 is som=
e
interface that is currently DOWN, the following command

  ip link add link eth0 name eth0.1 up type vlan id 1

never returns and the kernel printks the following lines every few seco=
nds

  unregister_netdevice: waiting for eth0.1 to become free. Usage count =
=3D 2

I understand that the kernel should prevent me from creating a VLAN int=
erface
that's initially up when loose-binding is off and the master interface =
is down
(and indeed there is absolutely no problem when loose-binding is on), b=
ut the
unregistering of the currently-being-registered device should not block=
 like
that.  It appears there are too few dev_puts compared to dev_holds in t=
here.

Regards,

Ignacy

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
