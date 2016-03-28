From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 13:51:46 -0700
Message-ID: <1459198306.6473.126.camel@edumazet-glaptop3.roam.corp.google.com>
References: <56F8987B.5030501@gmail.com> <56F92E21.30509@gmail.com>
	 <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>
	 <20160328.152959.1109841569654352040.davem@davemloft.net>
	 <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
	 <1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu,
	sploving1@gmail.com, pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33659 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbcC1Uvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 16:51:48 -0400
In-Reply-To: <1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 13:46 -0700, Eric Dumazet wrote:

> We have at least 384 bytes of padding in skb->head (this is struct
> skb_shared_info).
> 
> Whatever garbage we might read, current code is fine.
> 
> We have to deal with a false positive here.

Very similar to the one fixed in 
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=10ec9472f05b45c94db3c854d22581a20b97db41
