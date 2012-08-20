From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: Protect packet sk list with mutex
Date: Mon, 20 Aug 2012 21:05:33 +0200
Message-ID: <1345489533.5158.354.camel@edumazet-glaptop>
References: <50324EBC.9060804@parallels.com>
	 <1345475500.5158.321.camel@edumazet-glaptop>
	 <50327D8A.5010400@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64846 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267Ab2HTTFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 15:05:38 -0400
Received: by bkwj10 with SMTP id j10so1966399bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 12:05:37 -0700 (PDT)
In-Reply-To: <50327D8A.5010400@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 22:10 +0400, Pavel Emelyanov wrote:

> AFAIU now this is the case for e.g. TCP sockets since they can be created in 
> rx code. For packet I've found no places where these stats can be modified other
> than those two in af_packet.c

sock_prot_inuse_add() uses __this_cpu_add(), and on non x86, needs to be
safe against preemption ( or irq if applicable)

Changing spin_lock_bh() to mutex_lock() breaks this.
