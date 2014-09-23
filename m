From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip6_udp_tunnel fails to load
Date: Tue, 23 Sep 2014 08:39:37 -0700
Message-ID: <1411486777.26859.189.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54218FED.4080102@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Zhou <azhou@nicira.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Eyal perry <eyalpe@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:41021 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbaIWPjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 11:39:36 -0400
Received: by mail-pd0-f173.google.com with SMTP id y10so6658418pdj.4
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 08:39:36 -0700 (PDT)
In-Reply-To: <54218FED.4080102@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-23 at 18:21 +0300, Eyal perry wrote:
> Hello Andy,
> 
> Lately I've start to observe a phenomena where the mlx4_en driver
> couldn't load on my system as a result of an 'Unknown symbol in module'.
> 
> [ 1277.458715] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
> [ 1277.486810] ip6_udp_tunnel: Unknown symbol __put_net (err 0)
> 
> Apparently, the mlx4_en driver is depend on the vxlan driver, which
> depends on the ip6_udp_tunnel module which fails to load.
> 
> 1. I've bisected this issue down to the following commit:
> fd38441 udp_tunnel: Seperate ipv6 functions into its own file.
> 
> 2. on a different host with a different .config, the module is loads
> cleanly.
> 
> 3. my sources are based on net-next commit
> 6d967f8 udp_tunnel: Only build ip6_udp_tunnel.c when IPV6 is selected
> 
> I'll send you both of the .config files in a private message.
> 
> This issue is making any driver which is depend on vxlan/ip6_udp_tunnel
> unusable, please take a look and fix

Have you tried this patch ?

https://patchwork.ozlabs.org/patch/392275/

Thanks
