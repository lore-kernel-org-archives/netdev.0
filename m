From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window
 transitions
Date: Wed, 19 Feb 2014 11:27:28 -0800
Message-ID: <1392838048.18849.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
	 <20140219.131708.562226572566677127.davem@davemloft.net>
	 <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140219185949.GA1179@order.stressinduktion.org>
	 <20140219191831.GA7119@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50892 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921AbaBST1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:27:30 -0500
Received: by mail-pa0-f52.google.com with SMTP id bj1so812981pad.25
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 11:27:29 -0800 (PST)
In-Reply-To: <20140219191831.GA7119@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 20:18 +0100, Florian Westphal wrote:

> sure, I can send v2 but I'll wait for (n)ack from Eric first
> before considering it.
> 
> tcp_transmit_skb (caller of tcp_select_window) also uses _BH
> which is why it ended up in tcp_select_window.

Yes, it seems the NET_INC_STATS_BH() in tcp_transmit_skb() should really
be a NET_INC_STATS(), even if it currently doesn't matter, even on 32bit
arches.
