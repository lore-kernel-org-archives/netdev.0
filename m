From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the
 slaves mac address
Date: Wed, 24 Nov 2010 16:44:40 -0800
Message-ID: <AANLkTinoWQg_a9pd44+dOm=e1sWhSy=mivNJkEJk1N8y@mail.gmail.com>
References: <AANLkTinpO=FmoecfV8epubXU4OrhFsXJ7-Kc68yNhMEs@mail.gmail.com> <31169.1290641617@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Strand <dpstrand@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <31169.1290641617@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

based on the new code, the behavior of ifenslave works the same.


>-       if (bond->slave_cnt =3D=3D 0)
>+       if (is_zero_ether_addr(bond->dev->dev_addr))
>-              memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
>-                            slave_dev->addr_len);
> +            bond_sethwaddr(bond, slave_dev);


On Wed, Nov 24, 2010 at 3:33 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> David Strand <dpstrand@gmail.com> wrote:
>
>>Restore the check for a missing mac address before adopting the first
>>slaves as it's own. This regression was introduced in:
>>http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.36.y.git=
;a=3Dcommit;h=3Dc20811a79e671a6a1fe86a8c1afe04aca8a7f085
>
> =A0 =A0 =A0 =A0How exactly is this a regression? =A0The above referen=
ced patch
> changes the method used to decide if the bonding master needs to have
> it's MAC address set. =A0The original way was "bonding master's MAC i=
s
> zero," after the above, it's "adding first slave."
>
> =A0 =A0 =A0 =A0Do you have some use case that manually sets the maste=
r's MAC
> address prior to adding any slaves?
>
> =A0 =A0 =A0 =A0-J
>
>>Signed-off-by: David Strand dpstrand@gmail.com
>>---
>>diff -uprN a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
>>--- a/drivers/net/bonding/bond_main.c =A02010-11-24 11:36:58.12564000=
0 -0800
>>+++ b/drivers/net/bonding/bond_main.c =A02010-11-24 11:40:58.17564000=
0 -0800
>>@@ -1577,8 +1577,9 @@ int bond_enslave(struct net_device *bond
>> =A0 =A0 =A0 /* If this is the first slave, then we need to set the m=
aster's hardware
>> =A0 =A0 =A0 =A0* address to be the same as the slave's. */
>> =A0 =A0 =A0 if (bond->slave_cnt =3D=3D 0)
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(bond->dev->dev_addr, slave_dev->d=
ev_addr,
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave_dev->addr_len);
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (is_zero_ether_addr(bond->dev->dev_ad=
dr))
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(bond->dev->dev_ad=
dr, slave_dev->dev_addr,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slave_dev->=
addr_len);
>>
>>
>> =A0 =A0 =A0 new_slave =3D kzalloc(sizeof(struct slave), GFP_KERNEL);
>
> ---
> =A0 =A0 =A0 =A0-Jay Vosburgh, IBM Linux Technology Center, fubar@us.i=
bm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
-----------------------------------------------------------------------=
---------
