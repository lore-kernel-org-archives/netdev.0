From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] jme: fix panic on load
Date: Sun, 31 Oct 2010 17:32:12 +0100
Message-ID: <1288542732.2660.57.camel@edumazet-laptop>
References: <1288539978.2660.47.camel@edumazet-laptop>
	 <20101031163428.M61655@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56546 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756066Ab0JaQcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 12:32:19 -0400
Received: by wwe15 with SMTP id 15so5237382wwe.1
        for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 09:32:18 -0700 (PDT)
In-Reply-To: <20101031163428.M61655@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 novembre 2010 =C3=A0 00:39 +0800, Guo-Fu Tseng a =C3=A9crit=
 :
> Can this patch be modified to move the netif_stop_queue()
> after register_netdev() ?
> It seems the __QUEUE_STATE_XOFF is not set after the register_netdev.
> The tx_queue was kcalloc() ed without touching state flags.
>=20

Real question is : why this netif_stop_queue() was needed at the first
place ?

We believe (David and others), that using before ndo_open() is useless
or a sign of design error.

http://www.spinics.net/lists/netdev/msg145481.html


Refs: commit c117e4a2bb4911

If your driver doesnt work after my change, then another patch is
needed, but not using netif_stop_queue() right after register_netdev()



