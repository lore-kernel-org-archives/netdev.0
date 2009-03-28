From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: [Fwd: net-tools future]
Date: Sat, 28 Mar 2009 14:14:57 +0100
Message-ID: <49CE22D1.6090109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:43392 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbZC1NPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 09:15:04 -0400
Received: by ewy9 with SMTP id 9so1421571ewy.37
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 06:14:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-------- Original Message --------
Subject: net-tools future
Date: Sun, 15 Mar 2009 17:30:18
=46rom: Mart=EDn Ferrari <tincho@debian.org>
To: debian-devel@@lists.debian.org

Hi,

Luk Claes and me, as the current maintainers of net-tools, we've been
thinking about it's future. Net-tools has been a core part of Debian an=
d
any other linux based distro for many years, but it's showing its age.

It doesnt support many of the modern features of the linux kernel, the
interface is far from optimal and difficult to use in automatisation,
and also, it hasn't got much love in the last years.

On the other side, the iproute suite, introduced around the 2.2 kernel
line, has both a much better and consistent interface, is more powerful=
,
and is almost ten years old, so nobody would say it's untested.

Hence, our plans are to replace net-tools completely with iproute, mayb=
e
leading the route for other distributions to follow. Of course, most
people and tools use and remember the venerable old interface, so the
first step would be to write wrappers, trying to be compatible with
net-tools.

At the same time, we believe that most packages using net-tools should
be patched to use iproute instead, while others can continue using the
wrappers for some time. The ifupdown package is obviously the first
candidate, but it seems that a version using iproute has been available
in experimental since 2007.

So, the roadmap would be:
- Send patches to net-tools using packages to use iproute instead
- Development of the wrapper scripts
- Uploading to experimental a net-tools-compat package, to allow wider
testing.
- Upload to unstable

About the wrapper scripts:
 * ipconfig, route: the most difficult ones, both can be replaced by
calls to "ip", maybe except for some obscure options.
 * netstat : sstat provides almost the same information, just some
formatting changes and parsing the command line
 * rarp should be dropped, as the linux kernel doesn't support it
anymore, since the 2.3 series. The replacement, arpd, is already
included in iproute.
 * ipmaddr works exactly as "ip maddr", in fact, the code is from the
iproute sources. Same for iptunnel and "ip tunnel". In both cases,
they're just replaced by a symlinkm, as the ip command recognises that.
 * nameif: can be replaced by "ip link", not sure if it's worth the
effort (does anybody actually use it?)

Problematic tools:
 * mii-tool: it could be dropped and replaced by a pointer to ethtool a=
s
it's not meant to be used automatically by scripts. On the other hand,
it's distributed as a stand-alone tool [0] and we could do the same.
 * plipsetup, slattach: we don't know of any replacement for those, but
could be distributed separately too. Also, it's dubious if anyone still
uses them.

0: http://freshmeat.net/projects/mii-tool/

--=20
Mart=ED=ADn Ferrari <tincho@debian.org>

--
To UNSUBSCRIBE, email to debian-devel-REQUEST@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debi=
an.org

---end---
