From: Martin Filip <nexus+kernel@smoula.net>
Subject: TUN device performance regression
Date: Mon, 14 Apr 2014 13:31:58 +0200
Message-ID: <1397475118.11864.5.camel@interceptor.in.smoula.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lGpTmJtkLg0efAxiJ+SG"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scarab.smoula.net ([83.240.14.6]:42517 "EHLO scarab.smoula.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023AbaDNLlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 07:41:39 -0400
Received: from localhost (localhost [127.0.0.1])
	by scarab.smoula.net (Postfix) with ESMTP id 36D9F2550D
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 13:32:05 +0200 (CEST)
Received: from scarab.smoula.net ([127.0.0.1])
	by localhost (scarab.smoula.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QRDsUPJF6QA4 for <netdev@vger.kernel.org>;
	Mon, 14 Apr 2014 13:31:59 +0200 (CEST)
Received: from [IPv6:2001:470:5950:b00c::1] (interceptor.smoula.net [IPv6:2001:470:5950:b00c::1])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by scarab.smoula.net (Postfix) with ESMTPSA id 661DF2605A
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 13:31:59 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lGpTmJtkLg0efAxiJ+SG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hello,

I've noticed significant TUN device performance drop between 3.13 and
3.14 kernels, problem seems to persist until current git version.

With good kernel I can achieve full 100mbps through openvpn without any
problem, with problematic kernel TX performance drops down to ~50kbps.

According to git bisect it seems that root of all evil is commit
53d6471cef17262d3ad1c7ce8982a234244f68ec.

I can confirm that performance is great again with current kernel when I
revert this one.

-- 
Martin Filip
e-mail: nexus@smoula.net
jabberID: nexus@smoula.net
http://www.smoula.net


--=-lGpTmJtkLg0efAxiJ+SG
Content-Disposition: attachment; filename="bisect.log"
Content-Type: text/x-log; name="bisect.log"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

git bisect start
# bad: [c9eaa447e77efe77b7fa4c953bd62de8297fd6c5] Linux 3.15-rc1
git bisect bad c9eaa447e77efe77b7fa4c953bd62de8297fd6c5
# good: [d8ec26d7f8287f5788a494f56e8814210f0e64be] Linux 3.13
git bisect good d8ec26d7f8287f5788a494f56e8814210f0e64be
# good: [d265d9ac6c7c3201f0fea737cdf9c74e50415178] [media] exynos4-is: Use external s5k6a3 sensor driver
git bisect good d265d9ac6c7c3201f0fea737cdf9c74e50415178
# bad: [ec0159503ae74aeb834e78366bdf4b9663ca1129] hwmon: (k10temp) Add support for AMD F16 M30h processor
git bisect bad ec0159503ae74aeb834e78366bdf4b9663ca1129
# bad: [c70929147a10fa4538886cb23b934b509c4c0e49] Merge tag 'sound-3.15-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect bad c70929147a10fa4538886cb23b934b509c4c0e49
# bad: [683b6c6f82a60fabf47012581c2cfbf1b037ab95] Merge branch 'irq-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect bad 683b6c6f82a60fabf47012581c2cfbf1b037ab95
# bad: [462bf234a82ae1ae9d7628f59bc81022591e1348] Merge branch 'core-locking-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect bad 462bf234a82ae1ae9d7628f59bc81022591e1348
# good: [8712a00514e50aafa7c9bf5cd3955fa60758e53b] Merge branch 'akpm' (patches from Andrew Morton)
git bisect good 8712a00514e50aafa7c9bf5cd3955fa60758e53b
# good: [92f99731e61a3487781762d4e6ae8b1576e68e07] Merge tag 'sound-3.14' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect good 92f99731e61a3487781762d4e6ae8b1576e68e07
# good: [f217c44ebd41ce7369d2df07622b2839479183b0] Merge tag 'trace-fixes-v3.14-rc7-v2' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace
git bisect good f217c44ebd41ce7369d2df07622b2839479183b0
# bad: [49d8137a4039c63c834827f4bfe875e27bb9c521] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad 49d8137a4039c63c834827f4bfe875e27bb9c521
# bad: [fc92f745f8d0d3736ce5afb00a905d7cc61f9c46] bridge: Fix crash with vlan filtering and tcpdump
git bisect bad fc92f745f8d0d3736ce5afb00a905d7cc61f9c46
# good: [97a5221f56bad2e1c7e8ab55da4ac4748ef59c64] net/mlx4_core: pass pci_device_id.driver_data to __mlx4_init_one during reset
git bisect good 97a5221f56bad2e1c7e8ab55da4ac4748ef59c64
# good: [99b192da9c99284ad3374132e56f66995cadc6b4] bridge: Fix handling stacked vlan tags
git bisect good 99b192da9c99284ad3374132e56f66995cadc6b4
# good: [c15b1ccadb323ea50023e8f1cca2954129a62b51] ipv6: move DAD and addrconf_verify processing to workqueue
git bisect good c15b1ccadb323ea50023e8f1cca2954129a62b51
# good: [898602a049504dea256e696ee3152dc0b788a393] MAINTAINERS: bonding: change email address
git bisect good 898602a049504dea256e696ee3152dc0b788a393
# bad: [53d6471cef17262d3ad1c7ce8982a234244f68ec] net: Account for all vlan headers in skb_mac_gso_segment
git bisect bad 53d6471cef17262d3ad1c7ce8982a234244f68ec
# first bad commit: [53d6471cef17262d3ad1c7ce8982a234244f68ec] net: Account for all vlan headers in skb_mac_gso_segment

--=-lGpTmJtkLg0efAxiJ+SG--
