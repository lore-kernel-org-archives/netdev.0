From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 06:16:49 -0700
Message-ID: <1489411009.28631.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <201703132013.YIF2VUWv%fengguang.wu@intel.com>
         <1489410474.28631.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, kbuild-all@01.org,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36498 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750959AbdCMNQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 09:16:52 -0400
Received: by mail-pg0-f66.google.com with SMTP id 25so18030870pgy.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 06:16:51 -0700 (PDT)
In-Reply-To: <1489410474.28631.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-13 at 06:07 -0700, Eric Dumazet wrote:

> I removed the include <net/budy_poll.h>
> 
> It seems we need <net/ip.h>.

Yes, I will add this to v2 :

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index de455c8a2dec389cfeca6b6d474a6184d6acf618..a71554649c25383bb765fa8220bc9cd490247aee 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -43,6 +43,7 @@
 #include <linux/vmalloc.h>
 #include <linux/irq.h>
 
+#include <net/ip.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ip6_checksum.h>
 #endif
