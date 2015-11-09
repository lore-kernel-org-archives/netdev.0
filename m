From: Wang Yesheng <msz006c1a@gmail.com>
Subject: Question regarding skb forwarding
Date: Sun, 8 Nov 2015 23:53:56 -0500
Message-ID: <CABfWJ7QWf=2ie8TNseYhui=GfG2bKn+w7+xPK9q7n3byVcRf+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38675 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbbKIEx5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 23:53:57 -0500
Received: by igbxm8 with SMTP id xm8so44629650igb.1
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 20:53:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I=E2=80=99ve been trying to create a bridge like driver for a while. Th=
e
project is running into a wall due to the inability of seeing either
netdevice_ops structure or hard_start_xmit function from my device
driver in both Intel ixgbe and e1000e drivers.

Basically, I have a structure preserving all struct net_device
pointers running on system. I intend to send a skb via calling either
dev->netdev_ops->ndo_start_xmit() or dev->hard_start_xmit(). Long
story short, netdev_ops is a NULL pointer in my build for both ixgbe
and e1000e and hard_start_xmit() is not a member function of struct
net_device in 3.13.0 kernel.

I borrowed the idea of calling dev_queue_xmit(skb) instead from kernel
bridge driver but this is also plagued by the fact that netdev_ops
does not exist, as dev_queue_xmit will subsequently use netdev_ops
without guard.

Are my approaches off? What did I do wrong? Does anyone have any idea
as why my ixgbe and e1000e driver builds do not have netdev_ops
exposed in struct net_device pointer for the hardware ports?

Environment:
Ubuntu 14.04 LTS with kernel version 3.13.0-66-generic
Gcc 4.8
Ixgbe source version 4.0.3
e1000e source version 3.1.0.2

Thanks ahead to everyone.

Regards,
Andy
