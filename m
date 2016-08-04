From: Alexander Heinlein <alexander.heinlein@secunet.com>
Subject: IPIP tunnel with fixed TTL but no DF bit
Date: Thu, 4 Aug 2016 08:20:24 +0200
Message-ID: <1b4cfd95-4242-c0a6-7cd4-43fa037e2bae@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <nicolas.dichtel@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56474 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbcHDGw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 02:52:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to know why ip_tunnel_ioctl() enforces the DF bit whenever
the tunnel device has a fixed TTL set. The same restriction is enforced
by iproute2 (iptunnel.c and link_iptnl.c).

Ideally I would like to use an IPIP tunnel with a fixed TTL but no DF
bit set. Otherwise for non-TCP packets that are larger than the PMTU
size the kernel will send ICMP packets to end systems. However these
ICMP packets are ignored by the end system since the original packets
didn't have the DF bit set. As a result, non-TCP packets larger than the
PMTU are being dropped.

Regards
Alex
