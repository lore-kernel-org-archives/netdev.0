From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] inet: add IP_BIND_ADDRESS_NO_PORT to
 overcome bind(0) limitations
Date: Sat, 06 Jun 2015 23:57:33 -0700 (PDT)
Message-ID: <20150606.235733.812264566485784834.davem@davemloft.net>
References: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
	<CADVnQy=qbyTUdCPvDv8UbcuXJAsNhQVSiJCo83e9k8s8OWOF8w@mail.gmail.com>
	<1433650677.29864.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org,
	mtk.manpages@gmail.com, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbbFGG5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 02:57:36 -0400
In-Reply-To: <1433650677.29864.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 06 Jun 2015 21:17:57 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When an application needs to force a source IP on an active TCP socket
> it has to use bind(IP, port=x).
> 
> As most applications do not want to deal with already used ports, x is
> often set to 0, meaning the kernel is in charge to find an available
> port.
> But kernel does not know yet if this socket is going to be a listener or
> be connected.
> It has very limited choices (no full knowledge of final 4-tuple for a
> connect())
> 
> With limited ephemeral port range (about 32K ports), it is very easy to
> fill the space.
> 
> This patch adds a new SOL_IP socket option, asking kernel to ignore
> the 0 port provided by application in bind(IP, port=0) and only
> remember the given IP address.
> 
> The port will be automatically chosen at connect() time, in a way
> that allows sharing a source port as long as the 4-tuples are unique.
> 
> This new feature is available for both IPv4 and IPv6 (Thanks Neal)
> 
> Tested:
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
