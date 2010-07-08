From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Bug handling devices with weird names
Date: Thu, 8 Jul 2010 19:08:07 +0200
Message-ID: <AANLkTinBvzfdiAldJkXfH_vOkCv_cK7hBhjmH1l2vHTd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34546 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab0GHRIJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 13:08:09 -0400
Received: by fxm14 with SMTP id 14so553309fxm.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 10:08:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to dev_valid_name (net/core/dev.c), a valid device name is
one that doesn't include spaces, slashes, and is not "." or "..". But
if I create a device called "foo:", some operations fail:

# ip link add name foo: type dummy
# ip link list foo:
155: foo:: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN ioctl(SIOCG=
IFXQLEN)
failed: No such device

    link/ether 92:7f:4d:0d:8f:57 brd ff:ff:ff:ff:ff:ff

Strace reveals that the problem occurs when executing an ioctl:

ioctl(4, SIOCGIFTXQLEN, {ifr_name=3D"foo:", ???}) =3D -1 ENODEV (No suc=
h device)

ifconfig gets completely lost, of course:

$ /sbin/ifconfig foo:
foo:: error fetching interface information: Device not found

ioctl(5, SIOCGIFFLAGS, {ifr_name=3D"foo:", ???}) =3D -1 ENODEV (No such=
 device)


So, is this fixable or iproute should stop using the ioctl interface?
(dunno if netlink provides everything already)

--=20
Mart=EDn Ferrari
