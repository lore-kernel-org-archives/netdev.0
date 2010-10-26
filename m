From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GSO and IPv4 forwarding
Date: Tue, 26 Oct 2010 22:15:14 +0200
Message-ID: <1288124114.2652.25.camel@edumazet-laptop>
References: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51360 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090Ab0JZUPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:15:20 -0400
Received: by wwe15 with SMTP id 15so5145749wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 13:15:19 -0700 (PDT)
In-Reply-To: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 22:02 +0200, Kevin Wilson a =C3=A9crit =
:
> Hi,
> When we set a netdevice to support forwarding, we disable LRO.
> This is done because we don't want to forward an SKB which has been
> processed by LRO.
>=20
> This is done in inet_forward_change() in net/ipv4/devinet.c:
> We call dev_disable_lro(dev) in this method, when setting forwarding
> for the device.
> As a result, in ip_forward(), the packet will be dropped. (because
> skb_warn_if_lro(), called by this method,  returns TRUE)
>=20
> My question is:
> dev_disable_lro(dev) disable the LRO feature (NETIF_F_LRO) of the
> device. But suppose I have a device where GRO is enabled (and LRO is
> not). And let's say I set forwarding on this device.
>=20
> it seems to me that is such case, calling dev_disable_lro(dev)  in
> net_forward_change() to disable the LRO feature of the device (which
> is already disabled) is not enough, and in such case , GRO packets,
> which want to be forwarded,  will **not** be dropped in ip_forward().
> (since kb_warn_if_lro() will return false in this case)
>=20
> Is it so ? I am ready to send a patch fixing it, but I am a newbie in
> kernel, so I want to ask first.

GRO packets can be forwarded just fine.



