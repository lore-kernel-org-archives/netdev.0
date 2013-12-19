From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect
 forwarding path against pmtu spoofing
Date: Thu, 19 Dec 2013 10:42:12 -0500
Message-ID: <CABrhC0=NgAMs42Pg2uYhu8FHgaerOjzr3DMO0h1k5=1Nds1xbA@mail.gmail.com>
References: <20131218.173442.336109133942416102.davem@davemloft.net>
	<CABrhC0nG8Z01G-zVtObe40OuyDo0Jm5y+Lzy_r-zr2zmjfaKjQ@mail.gmail.com>
	<20131219000759.GF3505@order.stressinduktion.org>
	<20131219.001203.1942468169345523058.davem@davemloft.net>
	<20131219121757.GD14429@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:62488 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab3LSPmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 10:42:14 -0500
Received: by mail-we0-f178.google.com with SMTP id u57so1233886wes.23
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 07:42:12 -0800 (PST)
In-Reply-To: <20131219121757.GD14429@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 7:17 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Networking software on the end system which wants to guard against
> that kind of fragmentation can do so by using the various knobs to
> limit pmtu notification processing or use IP_PMTUDISC_INTERFACE to
> protect itself from sending fragments. (Note, all other methods but
> IP_PMTUDISC_INTERFACE have impact on all protocols, which could also
> break other services on that box). But if one has a linux router without
> complex icmp payload checking firewall enabled, the packets send without
> DF-bit will get fragmented at the next hops if an attacker managed to
> send such a spoofed pmtu notification to that router. They simply need to
> traceroute the path. We should avoid that!

The best practice for setting up routers usually involves separate
management and forwarding interfaces.  It's fairly simple to set up
firewall rules in such a configuration.

  -John
