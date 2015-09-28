From: Andrew Vagin <avagin@odin.com>
Subject: Re: [net] skbuff: Fix skb checksum flag on skb pull
Date: Mon, 28 Sep 2015 12:46:04 +0300
Message-ID: <20150928094525.GA770@odin.com>
Reply-To: <1441061746-1492-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([199.115.105.18]:39605 "EHLO
	mx2.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbbI1JqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 05:46:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

With this patch, I can't connect two local tcp ipv6 sockets.

[root@fc22-vm criu]# strace -e network python ipv6.py 
socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 3
bind(3, {sa_family=AF_INET6, sin6_port=htons(8976), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
listen(3, 1)                            = 0
socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET6, sin6_port=htons(8976), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 ETIMEDOUT (Connection timed out)

[root@fc22-vm criu]# cat ipv6.py 
import socket

srv = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
srv.bind(("::0", 8976))
srv.listen(1)
c = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
c.connect(("::1", 8976))
