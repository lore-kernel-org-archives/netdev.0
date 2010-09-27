From: James Chapman <jchapman@katalix.com>
Subject: Re: l2tpv3 support not yet in iproute2?
Date: Mon, 27 Sep 2010 18:26:38 +0100
Message-ID: <4CA0D3CE.7010208@katalix.com>
References: <loom.20100927T170521-559@post.gmane.org> <1285604596.3017.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpo234 <pommnitz@yahoo.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:57736 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759781Ab0I0RfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 13:35:18 -0400
In-Reply-To: <1285604596.3017.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/09/2010 17:23, Eric Dumazet wrote:
> Le lundi 27 septembre 2010 =E0 15:22 +0000, jpo234 a =E9crit :
>> Hello all,
>> some time ago James Chapman sent patches that add L2TPv3 support to =
iproute2:
>> http://kerneltrap.org/mailarchive/linux-netdev/2010/3/18/6272266/thr=
ead
>> While the kernel support arrived in 2.6.35 the user space configurat=
ion support
>> still seems to be missing:
>> iproute2-2.6.35$ find . -type f -iname "*.c" | xargs fgrep -i l2tp
>> doesn't find anything.
>>
>> Can somebody clarify the current situation?

Stephen Hemminger (maintainer of iproute2) rejected the patches because
they would add a dependency of libnl to iproute2. iproute2 uses
libnetlink, not libnl. Stephen's objections are reasonable.

The l2tpv3 API uses generic-netlink (genl) which is handled by libnl
APIs very well (and is the main reason why libnl was chosen in the firs=
t
place). To recode using libnetlink would require working with low level
libnetlink helpers to build/parse genl messages at low level,
effectively reimplementing some of what is already handled by libnl. I
don't have motivation or time to do this, though I'm happy to support
someone else doing so.

As a quick solution, I posted a new utility, l2tpv3tun, which does the
same as the iproute2 l2tpv3 patches in a standalone utility. l2tpv3tun
is at ftp://ftp.openl2tp.org/releases/l2tpv3tun-0.1.tar.gz

> Hmm, this reminds me l2tp locking is buggy and not yet fixed.
>=20
> http://kerneltrap.org/mailarchive/linux-netdev/2010/4/20/6275106
>=20
> James, any chance you could fix the locking ?

This dropped off my radar. I'm too busy right now but I'll look at it a=
s
soon as I can, unless someone else beats me to it.


--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

