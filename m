From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v4] xps: Transmit Packet Steering
Date: Wed, 27 Oct 2010 06:46:08 +0200
Message-ID: <1288154768.2652.82.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010262033520.2997@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51761 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab0J0EqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 00:46:14 -0400
Received: by wwe15 with SMTP id 15so336183wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 21:46:13 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010262033520.2997@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 20:38 -0700, Tom Herbert a =C3=A9crit :
> The benefits of XPS are improved locality in the per queue data
> structures.  Also, transmit completions are more likely to be done
> nearer to the sending thread, so this should promote locality back
> to the socket on free (e.g. UDP). =20


I dont understand this part of changelog :
We now early orphan packets before giving them to device.
(see skb_orphan_try())

So at completion time, we dont touch socket anymore.

However, we free skb, so this promotes locality on kmem caches, iff tx
completion is run on same cpu.



