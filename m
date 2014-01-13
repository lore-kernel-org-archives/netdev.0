From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Mon, 13 Jan 2014 13:36:52 -0800
Message-ID: <1389649012.31367.235.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <20140113.115913.1269834557058575064.davem@davemloft.net>
	 <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_a0cnqXHFk3zRuQQnRNUqMet=N3h10HPgTGghyGoh=xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:43811 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbaAMVgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 16:36:55 -0500
Received: by mail-yh0-f51.google.com with SMTP id l109so1663266yhq.10
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 13:36:55 -0800 (PST)
In-Reply-To: <CA+mtBx_a0cnqXHFk3zRuQQnRNUqMet=N3h10HPgTGghyGoh=xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 13:24 -0800, Tom Herbert wrote:

> 
> Or maybe nobody uses IPIP. ;-)

The bug happened even without IPIP being used on the node.

Changing one byte from 0x45 to 0x40 was enough to trigger it.

Since we do not perform header checksum in flow dissector, normal
corrupted traffic on the Internet would have a chance to trigger the
infinite loop.
