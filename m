From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: xfrm: is pmtu broken with ESP tunneling?
Date: Tue, 11 Feb 2014 03:32:58 +0100
Message-ID: <20140211023258.GC11150@order.stressinduktion.org>
References: <52F890D2.2060109@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ortwin =?utf-8?B?R2zDvGNr?= <odi@odi.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45049 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbaBKCdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 21:33:00 -0500
Content-Disposition: inline
In-Reply-To: <52F890D2.2060109@odi.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Mon, Feb 10, 2014 at 09:41:54AM +0100, Ortwin Gl=C3=BCck wrote:
> I am using Openswan to configure an IPSec VPN (using the xfrm/netkey=20
> backend). Large HTTP POST requests from the client seem to get stuck,=
=20
> because the outgoing packets are 1530 bytes (before being wrapped int=
o=20
> ESP packets). The problem goes away by setting sysctl=20
> net.ipv4.ip_no_pmtu_disc=3D1.

This setting will shrink the path mtu to min_pmtu when a frag needed ic=
mp is
received. It sounds like we calculate the path mtu incorreclty in case =
of
fragmentation.

> May have something to do with it:
> The tunneled network is 10.6.6.6/32 and I am SNAT'ing some destinatio=
ns=20
> to that IP, so they get routed through the tunnel. Any other networks=
=20
> are not to go through the tunnel.
>=20
> iptables -t nat -A POSTROUTING -d "${R}" -j SNAT --to-source 10.6.6.6
>=20
> It seems quite clear to me that xfrm is doing something wrong here.

Can you send a ip route get <ip> to the problematic target to see how
far off the calculated value is?

Thanks,

  Hannes
