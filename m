From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: =?UTF-8?Q?nonlocal=5Fbind=20and=20IPv=36?=
Date: Fri, 16 Dec 2011 10:53:48 +0100
Message-ID: <e21a2d9682b5d83fefe3f09a07316033@luffy.cx>
References: <1323879648-419-1-git-send-email-bernat@luffy.cx>
 <CAHo-OoxrYpFMBVfriB7HhL-BpMXJgCe1-mL4L8UpsDQJifMZvQ@mail.gmail.com>
 <m3zket9gqj.fsf@neo.luffy.cx>
 <20111216.020600.1695776769736304587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <zenczykowski@gmail.com>, <netdev@vger.kernel.org>,
	<yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:35377 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900Ab1LPJxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 04:53:51 -0500
In-Reply-To: <20111216.020600.1695776769736304587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2011 02:06:00 -0500 (EST), David Miller wrote:

>> OoO En  ce milieu  de nuit  =C3=A9toil=C3=A9e du vendredi  16 d=C3=A9=
cembre  2011,=20
>> vers
>> 04:58, Maciej =C5=BBenczykowski <zenczykowski@gmail.com> disait=C2=A0=
:
>>
>>> why not simply use the IP_TRANSPARENT or IP_FREEBIND socket=20
>>> options?
>>
>> Because  this requires  modifying each  affected software.  This =20
>> can be
>> difficult if you don't have the source code available.
>
> But it means that it would work on every single kernel verion out
> there.

Sure. But... The typical scenario for this setting is when you are=20
using something like VRRP. You have your web server running on several=20
nodes and only one of them has the appropriate IP address at the given=20
moment. Moreover, you have to bind to specific IP and not 0.0.0.0 for=20
other reasons (for example, when using several SSL virtualhosts).=20
Starting the web server only when a node gets the appropriate IP is not=
=20
possible because it increases downtime. Since this VRRP stuff is relate=
d=20
to system configuration, it seems sensible to have a system setting=20
equivalent to IP_FREEBIND socket options. This is ip_nonlocal_bind.

Moreover, I am just adding the IPv6 version of this setting. The IPv4=20
version already exists.
