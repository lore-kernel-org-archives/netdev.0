From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 2/3] bonding: use rcu_access_pointer() in
 bonding_show_mii_status()
Date: Tue, 15 Jul 2014 12:32:30 +0200
Message-ID: <20140715103230.GC28235@mikrodark.usersys.redhat.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
 <1405417604-7828-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:39560 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758108AbaGOKf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 06:35:29 -0400
Received: by mail-we0-f177.google.com with SMTP id w62so1949323wes.22
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 03:35:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405417604-7828-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 02:46:43AM -0700, Eric Dumazet wrote:
>curr_active_slave is rcu protected, and bonding_show_mii_status() only
>wants to check if pointer is NULL or not.
>
>Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Veaceslav Falico <vfalico@gmail.com>

>---
> drivers/net/bonding/bond_sysfs.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index daed52f68ce1..98db8edd9c75 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -492,8 +492,9 @@ static ssize_t bonding_show_mii_status(struct device *d,
> 				       char *buf)
> {
> 	struct bonding *bond = to_bond(d);
>+	bool active = !!rcu_access_pointer(bond->curr_active_slave);
>
>-	return sprintf(buf, "%s\n", bond->curr_active_slave ? "up" : "down");
>+	return sprintf(buf, "%s\n", active ? "up" : "down");
> }
> static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
>
>-- 
>2.0.0.526.g5318336
>
