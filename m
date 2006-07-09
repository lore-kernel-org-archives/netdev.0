From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] net/ipv4/netfilter/: fix SYSCTL=n compile
Date: Sun, 09 Jul 2006 05:37:35 +0200
Message-ID: <44B079FF.8060909@trash.net>
References: <20060708202023.GE5020@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:8126 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S964953AbWGIDhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2006 23:37:37 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060708202023.GE5020@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch fixes the following compile error with CONFIG_SYSCTL=n 
> introduced by commit 39a27a35c5c1b5be499a0576a35c45a011788bf8:

My fault I guess.

> <--  snip  -->
> 
> ...
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `tcp_error':
> ip_conntrack_proto_tcp.c:(.text+0x77af6): undefined reference to `ip_conntrack_checksum'
> net/built-in.o: In function `udp_error':
> ip_conntrack_proto_udp.c:(.text+0x78456): undefined reference to `ip_conntrack_checksum'
> net/built-in.o: In function `icmp_error':
> ip_conntrack_proto_icmp.c:(.text+0x7868f): undefined reference to `ip_conntrack_checksum'
> make: *** [.tmp_vmlinux1] Error 1

Thanks Adrian. Usually all bugs in ip_conntrack are duplicated in
nf_conntrack, please update your patch to take care of that as well.

