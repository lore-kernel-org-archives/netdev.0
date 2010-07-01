From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Thu, 01 Jul 2010 22:19:14 +0200
Message-ID: <1278015554.2782.11.camel@edumazet-laptop>
References: <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
	 <1276679284.2632.22.camel@edumazet-laptop>
	 <c38a6e1add643eb78bd0d28ee3984cf4@dondevamos.com>
	 <20100630.131616.233403329.davem@davemloft.net>
	 <a372414c0d74e9ab599d095627353d94@dondevamos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Pedro Garcia <pedro.netdev@dondevamos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:55865 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756738Ab0GAUTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 16:19:20 -0400
Received: by ewy23 with SMTP id 23so884288ewy.19
        for <netdev@vger.kernel.org>; Thu, 01 Jul 2010 13:19:19 -0700 (PDT)
In-Reply-To: <a372414c0d74e9ab599d095627353d94@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 juillet 2010 =C3=A0 20:47 +0200, Pedro Garcia a =C3=A9crit =
:
> The patch with the modifications suggested by David.
>=20
> - Without the 8021q module loaded in the kernel, all 802.1p packets=20
> (VLAN 0 but QoS tagging) are silently discarded (as expected, as=20
> the protocol is not loaded).
>=20
> - Without this patch in 8021q module, these packets are forwarded to=20
> the module, but they are discarded also if VLAN 0 is not configured,
> which should not be the default behaviour, as VLAN 0 is not really
> a VLANed packet but a 802.1p packet. Defining VLAN 0 makes it almost
> impossible to communicate with mixed 802.1p and non 802.1p devices on
> the same network due to arp table issues.
>=20
> - Changed logic to skip vlan specific code in vlan_skb_recv if VLAN=20
> is 0 and we have not defined a VLAN with ID 0, but we accept the=20
> packet with the encapsulated proto and pass it later to netif_rx.
>=20
> - In the vlan device event handler, added some logic to add VLAN 0=20
> to HW filter in devices that support it (this prevented any traffic
> in VLAN 0 to reach the stack in e1000e with HW filter under 2.6.35,
> and probably also with other HW filtered cards, so we fix it here).
>=20
> - In the vlan unregister logic, prevent the elimination of VLAN 0=20
> in devices with HW filter.
>=20
> - The default behaviour is to ignore the VLAN 0 tagging and accept
> the packet as if it was not tagged, but we can still define a=20
> VLAN 0 if desired (so it is backwards compatible).
>=20
> Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>


Seems fine but you need to respin your patch against latest net-next-2.=
6
tree.

Check your tree got commit 9618e2ffd78aaa (vlan: 64 bit rx counters)

Thanks !


