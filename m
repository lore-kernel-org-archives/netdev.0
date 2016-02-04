From: =?UTF-8?B?QXJrYWRpdXN6IEJ1YmHFgmE=?= <arkadiusz.bubala@open-e.com>
Subject: Connection remains in the ESTABLISHED state when the virtual IP is
 down.
Date: Thu, 04 Feb 2016 08:49:08 +0100
Message-ID: <56B30274.8020409@open-e.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:62149 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcBDHvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:51:08 -0500
Received: from [192.168.176.17] ([85.14.118.246]) by mrelayeu.kundenserver.de
 (mreue101) with ESMTPSA (Nemesis) id 0LqD7g-1ZnnD70eau-00dqyI for
 <netdev@vger.kernel.org>; Thu, 04 Feb 2016 08:51:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I encountered following issue:
when I connect with NFS server through virtual IP then I remove this IP=
=20
netstat still shows that connection is ESTABLISHED. When I put down=20
whole interface all ESTABLISHED connections disappear.  The kernel=20
version is 3.10.92.

How to reproduce.

create virtual IP:

ip addr add 88.88.88.1/24 dev eth0 label eth0:0 (or ifconfig eth0:0=20
88.88.88.1)

then make connection from the NFS client. In netstat there is:
tcp        0      0 88.88.88.1:2049         88.88.88.2:765 ESTABLISHED-

and delete virtual IP:
ip addr del 88.88.88.1/24 dev eth0 (or ifconfig eth0:0 down)

the netstat still shows that conneciton is ESTABLISHED and remains in=20
that state for about 5 minutes. Even if I recreate virtual IP I can't=20
access to the server until it disappears.

When the whole interface is put down (ifconfig eth0 down)  the netstat=20
doesn't show any entries for my virtual IP and if I put it up again I=20
can access to the server immediately.

Shouldn't the ESTABLISHED connections be removed also when virtual IP i=
s=20
down? Or maybe there is any sysctl option to change that behaviour?

--=20
Best regards
Arkadiusz Buba=C5=82a
Open-E Poland Sp. z o.o.
www.open-e.com
