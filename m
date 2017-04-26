From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net 3/3] team: use a larger struct for mac address
Date: Wed, 26 Apr 2017 07:40:33 +0200
Message-ID: <20170426054033.GA1867@nanopsycho.orion>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
 <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33878 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1949080AbdDZFkh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:40:37 -0400
Received: by mail-wm0-f65.google.com with SMTP id z129so30272922wmb.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 22:40:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 26, 2017 at 07:03:23AM CEST, xiyou.wangcong@gmail.com wrote:
>IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
>but in many places especially bonding, we use struct sockaddr
>to copy and set mac addr, this could lead to stack out-of-bounds
>access.
>
>Fix it by using a larger address storage.
>
>Reported-by: Andrey Konovalov <andreyknvl@google.com>
>Cc: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>---
> drivers/net/team/team.c | 9 ++++++---
> 1 file changed, 6 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 85c0124..88878f1 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -60,10 +60,13 @@ static struct team_port *team_port_get_rtnl(const struct net_device *dev)
> static int __set_port_dev_addr(struct net_device *port_dev,
> 			       const unsigned char *dev_addr)
> {
>-	struct sockaddr addr;
>+	struct {
>+		unsigned short type;
>+		unsigned char addr[MAX_ADDR_LEN];
>+	} addr;

Wouldn't it make sense to define this struct somewhere in the core
headers?


> 
>-	memcpy(addr.sa_data, dev_addr, port_dev->addr_len);
>-	addr.sa_family = port_dev->type;
>+	memcpy(addr.addr, dev_addr, port_dev->addr_len);
>+	addr.type = port_dev->type;
> 	return dev_set_mac_address(port_dev, &addr);
> }
> 
>-- 
>2.5.5
>
