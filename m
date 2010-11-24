From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the slaves mac address
Date: Wed, 24 Nov 2010 15:33:37 -0800
Message-ID: <31169.1290641617@death>
References: <AANLkTinpO=FmoecfV8epubXU4OrhFsXJ7-Kc68yNhMEs@mail.gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Strand <dpstrand@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <AANLkTinpO=FmoecfV8epubXU4OrhFsXJ7-Kc68yNhMEs@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Strand <dpstrand@gmail.com> wrote:

>Restore the check for a missing mac address before adopting the first
>slaves as it's own. This regression was introduced in:
>http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.36.y.git;a=commit;h=c20811a79e671a6a1fe86a8c1afe04aca8a7f085

	How exactly is this a regression?  The above referenced patch
changes the method used to decide if the bonding master needs to have
it's MAC address set.  The original way was "bonding master's MAC is
zero," after the above, it's "adding first slave."

	Do you have some use case that manually sets the master's MAC
address prior to adding any slaves?

	-J

>Signed-off-by: David Strand dpstrand@gmail.com
>---
>diff -uprN a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>--- a/drivers/net/bonding/bond_main.c	2010-11-24 11:36:58.125640000 -0800
>+++ b/drivers/net/bonding/bond_main.c	2010-11-24 11:40:58.175640000 -0800
>@@ -1577,8 +1577,9 @@ int bond_enslave(struct net_device *bond
> 	/* If this is the first slave, then we need to set the master's hardware
> 	 * address to be the same as the slave's. */
> 	if (bond->slave_cnt == 0)
>-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>-		       slave_dev->addr_len);
>+		if (is_zero_ether_addr(bond->dev->dev_addr))
>+			memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>+			       slave_dev->addr_len);
>
>
> 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
