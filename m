From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
 (v2)
Date: Wed, 06 Apr 2011 13:07:49 -0700 (PDT)
Message-ID: <20110406.130749.35032326.davem@davemloft.net>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
	<1302118647-7931-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	therbert@google.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58749
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755015Ab1DFUI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:08:26 -0400
In-Reply-To: <1302118647-7931-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed,  6 Apr 2011 15:37:27 -0400

> properly record sk_rxhash in ipv6 sockets (v2)
> 
> Noticed while working on another project that flows to sockets which I had open
> on a test systems weren't getting steered properly when I had RFS enabled.
> Looking more closely I found that:
> 
> 1) The affected sockets were all ipv6
> 2) They weren't getting steered because sk->sk_rxhash was never set from the
> incomming skbs on that socket.
> 
> This was occuring because there are several points in the IPv4 tcp and udp code
> which save the rxhash value when a new connection is established.  Those calls
> to sock_rps_save_rxhash were never added to the corresponding ipv6 code paths.
> This patch adds those calls.  Tested by myself to properly enable RFS
> functionalty on ipv6.
> 
> Change notes:
> v2:
> 	Filtered UDP to only arm RFS on bound sockets (Eric Dumazet)
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Ok, I've decided to apply this to net-2.6

The current behavior even surprised me, I was pretty sure we had added
the hooks to both ipv4 and ipv6.

Thanks a lot Neil.
