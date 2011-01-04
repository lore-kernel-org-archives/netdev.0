From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 04 Jan 2011 11:35:51 -0800 (PST)
Message-ID: <20110104.113551.102540724.davem@davemloft.net>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jsing@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50305
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751014Ab1ADTfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 14:35:19 -0500
In-Reply-To: <1294122260-13245-1-git-send-email-jsing@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joel Sing <jsing@google.com>
Date: Tue,  4 Jan 2011 17:24:20 +1100

> The preferred source address is currently ignored for local routes,
> which results in all local connections having a src address that is the
> same as the local dst address. Fix this by respecting the preferred source
> address when it is provided for local routes.
> 
> This bug can be demonstrated as follows:
> 
>  # ifconfig dummy0 192.168.0.1
>  # ip route show table local | grep local.*dummy0
>  local 192.168.0.1 dev dummy0  proto kernel  scope host  src 192.168.0.1
>  # ip route change table local local 192.168.0.1 dev dummy0 \
>      proto kernel scope host src 127.0.0.1
>  # ip route show table local | grep local.*dummy0
>  local 192.168.0.1 dev dummy0  proto kernel  scope host  src 127.0.0.1
> 
> We now establish a local connection and verify the source IP
> address selection:
> 
>  # nc -l 192.168.0.1 3128 &
>  # nc 192.168.0.1 3128 &
>  # netstat -ant | grep 192.168.0.1:3128.*EST
>  tcp        0      0 192.168.0.1:3128        192.168.0.1:33228 ESTABLISHED
>  tcp        0      0 192.168.0.1:33228       192.168.0.1:3128  ESTABLISHED
> 
> Signed-off-by: Joel Sing <jsing@google.com>

Applied to net-2.6, thanks Joel.

If you guys want to mess with ternary operators and new macros,
please do that in net-next-2.6 the next time I merge or similar.

Thanks.
