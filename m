From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Re: Incorrect ARP behavior when multiple/none IPv4 address assigned
 to interface
Date: Wed, 24 Oct 2012 13:37:36 +0300
Message-ID: <5087C4F0.4070607@mail.ru>
References: <50867F51.3030500@mail.ru> <alpine.LFD.2.00.1210232317400.1780@ja.ssi.bg> <50879632.20909@mail.ru> <alpine.LFD.2.00.1210241106080.1616@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.ru ([94.100.176.130]:55999 "EHLO smtp2.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417Ab2JXKh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 06:37:56 -0400
Received: from [195.234.68.4] (port=35894 helo=tuxracer.localdomain)
	by smtp2.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1TQyLS-0004RD-4r
	for netdev@vger.kernel.org; Wed, 24 Oct 2012 14:37:54 +0400
In-Reply-To: <alpine.LFD.2.00.1210241106080.1616@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov =D0=BF=D0=B8=D1=88=D0=B5=D1=82:

> 	dummy module is usually used as blackhole for
> traffic or to hide addresses from other interfaces with
> some sysctl interface flags.
>
> 	For example, can it work in this way?:
>
> eth0: addr 10.0.1.1/24
> ip route 10.0.1.2/32 dev eth0 src 10.0.1.1
>
> eth1: addr 10.0.1.1/24
> ip route 10.0.1.3/32 dev eth1 src 10.0.1.1
>
> eth2: addr 10.0.2.1/24
> ip route 10.0.2.2/32 dev eth2 src 10.0.2.1
>
> 	By this way we have subnet on every device and
> we can prefer local IP from such subnet in inet_select_addr.
> May be arp_ignore=3D1/2 and arp_announce=3D1/2 can help here
> to put the needed restrictions, i.e. we should not expose
> addresses from other devices. It should not cause problem
> for proxy_arp because we have more specific /32 routes.
>

Yes, just apply proposed configuration to lab schema.

Everything works as expected with no extra arp_ignore/arp_announce
configuration. Even if I add second primary address 192.168.1.1/24 to=20
eth2, and introduce pc4 in same broadcast domain as pc3 (eth2).

Well, configuration with 3000 subinterfaces looks worse, but it works
with no extra patches/configuration.

Thank you for your help.

--=20
SP5474-RIPE
Sergey Popovich
