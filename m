From: David Strand <dpstrand@gmail.com>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the
 slaves mac address
Date: Wed, 1 Dec 2010 10:25:19 -0800
Message-ID: <AANLkTi=+jMkrgNjVQvOOn_zURiJ4rXu5LL9eA4o0T9db@mail.gmail.com>
References: <AANLkTinpO=FmoecfV8epubXU4OrhFsXJ7-Kc68yNhMEs@mail.gmail.com>
	<31169.1290641617@death>
	<AANLkTi=-DzUmopboX13V_cd=mZnmD=mBNNCuhQYF0PQQ@mail.gmail.com>
	<8879.1290741991@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8879.1290741991@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 25, 2010 at 7:26 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Ok, fair enough. =C2=A0If we want to get b=
ack to the original
> behavior, however, your patch should only test for zero MAC address
> instead of testing for zero MAC address in addition to first slave.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0-J
>
> ---
> =C2=A0 =C2=A0 =C2=A0 =C2=A0-Jay Vosburgh, IBM Linux Technology Center=
, fubar@us.ibm.com
>

Understood, that makes sense. The updated patch is below.

---
diff -uprN a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
--- a/drivers/net/bonding/bond_main.c	2010-11-24 11:36:58.125640000 -08=
00
+++ b/drivers/net/bonding/bond_main.c	2010-12-01 10:12:33.728640001 -08=
00
@@ -1576,7 +1576,7 @@ int bond_enslave(struct net_device *bond

 	/* If this is the first slave, then we need to set the master's hardw=
are
 	 * address to be the same as the slave's. */
-	if (bond->slave_cnt =3D=3D 0)
+	if (is_zero_ether_addr(bond->dev->dev_addr))
 		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
 		       slave_dev->addr_len);
