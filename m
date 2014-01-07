From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 07 Jan 2014 08:33:53 -0800
Message-ID: <1389112433.26646.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	 <1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:54939 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaAGQd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 11:33:56 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so588389pab.5
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 08:33:55 -0800 (PST)
In-Reply-To: <1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:
>  
> +
> +#define MAX_UDP_PORT (1 << 16)
> +extern const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT];

Thats 512 KB of memory.

This will greatly impact forwarding performance of UDP packets with
random ports, and will increase kernel memory size for embedded devices.
