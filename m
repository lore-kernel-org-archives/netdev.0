From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: add synchronize_net() after
 netdev_rx_handler_unregister
Date: Wed, 22 May 2013 18:52:17 -0700
Message-ID: <1369273937.3301.377.camel@edumazet-glaptop>
References: <519C8504.1080906@huawei.com>
	 <1369223145.3301.308.camel@edumazet-glaptop> <519D73CA.8090200@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>, Li Zefan <lizefan@huawei.com>
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36021 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757314Ab3EWBwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 21:52:20 -0400
Received: by mail-ob0-f172.google.com with SMTP id tb18so3304380obb.31
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 18:52:20 -0700 (PDT)
In-Reply-To: <519D73CA.8090200@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 09:41 +0800, dingtianhong wrote:

> I totally understand the commit [1] and know the problem that you met at that time,
> but its not a net core problem, its drivers problem, the function synchronize_net()
> need to follow netdev_rx_handler_unregister() even though netdev_rx_handler_unregister()
> has its own synchronize_net(), the commit [2] fcd99434f fix drivers problem follow your
> opinion, but miss synchronize_net(),so add it.
> 

No, driver is fine.

You absolutely not explained why you believe this is needed.

After netdev_rx_handler_unregister(), no packet will be delivered to the
bonding driver.
