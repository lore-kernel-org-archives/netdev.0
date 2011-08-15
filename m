From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-2.6] bonding:restore backup and inactive flag of
 slave
Date: Mon, 15 Aug 2011 16:18:12 +0000 (UTC)
Message-ID: <j2bgs2$pf5$1@dough.gmane.org>
References: <CANMAZFWYUqDDp+_9EOOubRcvC90zHO9NR7D_N5D=uTjokpgU6A@mail.gmail.com>
	<13dbe805d13bba461e50483c0162ce8bc1366204.1313403625.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:47388 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab1HOQSb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 12:18:31 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Qszrs-0000B8-EK
	for netdev@vger.kernel.org; Mon, 15 Aug 2011 18:18:24 +0200
Received: from 60.160.69.172 ([60.160.69.172])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 18:18:24 +0200
Received: from xiyou.wangcong by 60.160.69.172 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 18:18:24 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Aug 2011 18:25:16 +0800, Weiping Pan wrote:

> 
> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c index 38a83ac..3ed9827 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3419,9 +3419,27 @@ static int bond_xmit_hash_policy_l2(struct 
sk_buff *skb, int count)
>  static int bond_open(struct net_device *bond_dev) {
>  	struct bonding *bond = netdev_priv(bond_dev);
> +	struct slave *slave;
> +	int i;
>  
>  	bond->kill_timers = 0;
>  
> +	// restore slave->backup and slave->inactive


Please use C-style comment.

> +	read_lock(&bond->lock);
> +	read_lock(&bond->curr_slave_lock);
> +	if (bond->slave_cnt > 0) {


You can move the second read_lock() under this if().


