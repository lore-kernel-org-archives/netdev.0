From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: How to use ixp4xx_hss (or generic-hdlc?)
Date: Sat, 22 Nov 2008 00:09:50 +0100
Message-ID: <m3bpw8smkh.fsf@maximus.localdomain>
References: <b0438a630811200942nac803a4hb0c054bf28195cb3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48954 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753568AbYKUXJx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 18:09:53 -0500
In-Reply-To: <b0438a630811200942nac803a4hb0c054bf28195cb3@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Thu\, 20 Nov
 2008 18\:42\:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> Is there any kind of tutorials on using generic-hdlc interfaces?

Not much, Documentation/networking/generic-hdlc.txt.

> I
> just want to make a simple point-to-point connection between two
> devices using ixp4xx_hss. I would like the data to be packetized usin=
g
> hdlc.
> -  I suppose I should use sethdlc to configure the interface, but I a=
m
> not sure about the configuration except that I should set "hdlc"
> protocol (I hope).

Sure.

> - Then I should "open" the interface. I am trying with "ifconfig hdlc=
0
> up", but I obtain an "ifconfig: SIOCSIFFLAGS: Function not
> implemented". As my previous use of net devices has been using
> ethernet or wifi devices in an "IP world", I am not quite sure if
> ifconfig should be used in this case.

modprobe driver and maybe hdlc_raw
sethdlc hdlc0 hdlc
ifconfig hdlc0 up should work fine.

> - Then I hope that I should open a raw (SOCK_RAW) PF_PACKET socket
> with protocol IPPROTO_RAW? I am not using IP, so this does not seem t=
o
> be the correct protocol, but...

Seems entirely correct.

> - And the address to sendto the data? Should it be formed just using
> the name of the interface or it requires more data?

No, all data is sent to the other end :-)

> Thanks. I know these should be really newbie questions, but I am
> finding difficult to know how to manage a "serial" device using a
> netdev interface.

Actually it's a bit different than normal async serial ports - HDLC
means packets.
--=20
Krzysztof Halasa
