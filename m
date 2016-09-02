From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink: fdb dump: optimize by saving last
 interface markers
Date: Thu, 01 Sep 2016 21:54:30 -0700
Message-ID: <1472792070.5439.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472619405-50802-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nikolay@cumulusnetworks.com,
        wkok@cumulusnetworks.com, stephen@networkplumber.org,
        jhs@mojatatu.com, makita.toshiaki@lab.ntt.co.jp, jiri@resnulli.us,
        idosch@mellanox.com, netdev@vger.kernel.org, minoura@valinux.co.jp,
        Dept-GELinuxNICDev@qlogic.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35799 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbcIBEyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 00:54:54 -0400
Received: by mail-pa0-f67.google.com with SMTP id cf3so5070759pad.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 21:54:33 -0700 (PDT)
In-Reply-To: <1472619405-50802-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-30 at 21:56 -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>

> @@ -342,7 +342,7 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
>  					  struct netlink_callback *cb,
>  					  struct net_device *dev,
>  					  struct net_device *filter_dev,
> -					  int idx)
> +					  int *idx)
>  {
>         return idx;
>  }


Compiler is not happy with this change.

$ grep CONFIG_NET_SWITCHDEV .config
# CONFIG_NET_SWITCHDEV is not set

...

./include/net/switchdev.h: In function 'switchdev_port_fdb_dump':
./include/net/switchdev.h:347:8: warning: return makes integer from pointer without a cast [enabled by default]

Thanks.
