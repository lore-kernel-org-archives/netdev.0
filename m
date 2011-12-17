From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: nonlocal_bind and IPv6
Date: Sat, 17 Dec 2011 11:52:01 +0100
Message-ID: <m38vmb8o8e.fsf@neo.luffy.cx>
References: <m3zket9gqj.fsf@neo.luffy.cx>
	<20111216.020600.1695776769736304587.davem@davemloft.net>
	<e21a2d9682b5d83fefe3f09a07316033@luffy.cx>
	<20111216.131833.2127398230815526406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:52635 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab1LQKwG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 05:52:06 -0500
In-Reply-To: <20111216.131833.2127398230815526406.davem@davemloft.net> (David
	Miller's message of "Fri, 16 Dec 2011 13:18:33 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OoO Pendant  le repas  du vendredi 16  d=C3=A9cembre 2011, vers  19:18,=
 David
Miller <davem@davemloft.net> disait=C2=A0:

>> Moreover, I am just adding the IPv6 version of this setting. The IPv=
4
>> version already exists.

> I don't think the ipv4 feature was a wise thing to add, so just becau=
se
> ipv4 has something doesn't automatically make it appropriate to suppo=
rt
> it in ipv6 too.  So please don't use arguments like that.

Here are my arguments against using IP_FREEBIND:
 1. It  needs to be applied to  all services, this will  take years. Al=
l
    services will need  an option just for that  (because usually a use=
r
    does not want  to be able to bind  to a non local IP).  We could us=
e
    some hacks with LD_PRELOAD, but that's just an hack.
 2. This option may just be unavailable because it is too low-level. Fo=
r
    example, it is not available  in Python socket implementation (but =
I
    can  still  hardcode  the  numerical  value).  If  I  use  some  we=
b
    framework, I will also have hard time to set this option.
 3. This is a Linux only option.

Here are the arguments for a sysctl:
 1. It  is  a system-wide  configuration:  you  configure  VRRP on  you=
r
    system, you enable this sysctl, nothing else to do.
 2. This is essentially a one-line modification. This will be quite eas=
y
    to maintain for years.
 3. This is the natural option for many people. See for example:
     http://thread.gmane.org/gmane.comp.web.haproxy/7317/focus=3D7318
 4. Without it, people just do horrible things:
     http://thread.gmane.org/gmane.comp.web.haproxy/7317/focus=3D7321

Did I convince you?
--=20
Vincent Bernat =E2=98=AF http://vincent.bernat.im

 /*
  * We used to try various strange things. Let's not.
  */
	2.2.16 /usr/src/linux/fs/buffer.c
