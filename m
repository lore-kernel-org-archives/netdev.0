From: Eyal perry <eyalpe@dev.mellanox.co.il>
Subject: ip6_udp_tunnel fails to load
Date: Tue, 23 Sep 2014 18:21:17 +0300
Message-ID: <54218FED.4080102@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:33940 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbaIWPVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 11:21:20 -0400
Received: by mail-we0-f178.google.com with SMTP id t60so4813121wes.37
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 08:21:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andy,

Lately I've start to observe a phenomena where the mlx4_en driver
couldn't load on my system as a result of an 'Unknown symbol in module'.

[ 1277.458715] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
[ 1277.486810] ip6_udp_tunnel: Unknown symbol __put_net (err 0)

Apparently, the mlx4_en driver is depend on the vxlan driver, which
depends on the ip6_udp_tunnel module which fails to load.

1. I've bisected this issue down to the following commit:
fd38441 udp_tunnel: Seperate ipv6 functions into its own file.

2. on a different host with a different .config, the module is loads
cleanly.

3. my sources are based on net-next commit
6d967f8 udp_tunnel: Only build ip6_udp_tunnel.c when IPV6 is selected

I'll send you both of the .config files in a private message.

This issue is making any driver which is depend on vxlan/ip6_udp_tunnel
unusable, please take a look and fix

Best Regards,
Eyal.
