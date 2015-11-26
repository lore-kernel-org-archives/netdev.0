From: Konstantin Shemyak <konstantin@shemyak.com>
Subject: IPv4 tunnels: why IP-IP and SIT enforce DF bit, but GRE does not?
Date: Thu, 26 Nov 2015 20:28:02 +0200
Message-ID: <56574F32.6070706@shemyak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub3.mail.dreamhost.com ([69.163.253.7]:46791 "EHLO
	homiemail-a76.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752853AbbKZS2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 13:28:05 -0500
Received: from homiemail-a76.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a76.g.dreamhost.com (Postfix) with ESMTP id 247CD45807C
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 10:28:05 -0800 (PST)
Received: from [10.0.0.5] (a91-152-80-240.elisa-laajakaista.fi [91.152.80.240])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: konstantin@shemyak.com)
	by homiemail-a76.g.dreamhost.com (Postfix) with ESMTPSA id B2D4D45807B
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 10:28:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel has taken the decision to always enforce DF bit on IPv4 
tunnels, which have fixed (not inherited) TTL (e.g. 
net/ipv4/ipip.c:ipip_tunnel_ioctl()). Commment by Alexey Kuznetsov in 
the head of ip_gre.c explains that the reason is attempting to avoid 
network loops.

But the commit c54419321455631 removed this enforcing from GRE tunnels,
not changing this behavior for IP-IP (net/ipv4/ipip.c) and SIT 
(net/ipv6/sit.c).

It can be discussed whether such enforcing of DF bit is exactly the
desired behavior, but shouldn't it at least be identical across IPv4 
tunnels?

Konstantin Shemyak
