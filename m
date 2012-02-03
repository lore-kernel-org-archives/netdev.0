From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Fri, 3 Feb 2012 16:43:10 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
 <1328304719.2480.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:35180 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913Ab2BCVnQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:43:16 -0500
In-Reply-To: <1328304719.2480.5.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=20
See inline.
-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Friday, February 03, 2012 1:32 PM
To: Shawn Lu
Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
Subject: Re: [PATCH] tcp: RST: binding oif to iif for tcp v4

Le vendredi 03 f=E9vrier 2012 =E0 12:16 -0800, Shawn Lu a =E9crit :
> Binding RST packet outgoing interface to incomming interface for tcp=20
> v4. This has few benefits:
> 1. tcp_v6_send_reset already did that.

I dont think so. ipv6 makes no special provision for RST.
[shawn LU] it's in  tcp_v6_send_response line 899 of tcp_ipv6.c
 fl6.flowi6_oif =3D inet6_iif(skb);

> 2. This helps tcp connect with SO_BINDTODEVICE set. When connection i=
s=20
> lost, we still able to sending out RST using same interface.

I dont understand this.

[shawn Lu] ok.  Tcp socket is bind to device using SO_BINDTODEVICE  to
Limit traffic to specifc interface.  Sometime, it may not have a valid
Source address to get through ip_route_output_key.=20

> 3. limit RST traffic in ingress interface reduce the impact of RST=20
> attack.
>=20
[shawn Lu] sometime, we want to limit unimportant traffic to certain in=
terface
To reduce impact on other interface=20

I dont understand this.

Me confused.

Why RST are special and should bypass/force routing decisions ?

This is going to break some setups.
