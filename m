From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (3/4) acenic - __iomem warnings cleanup
Date: Mon, 20 Sep 2004 11:32:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920113257.44b9bd7a@dell_ss3.pdx.osdl.net>
References: <20040920104431.0a96d6c1@dell_ss3.pdx.osdl.net>
	<414F199B.3090806@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@wildopensource.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <414F199B.3090806@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 13:55:39 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Remaining warnings are because tx_ring can be either in i/o or not
> > depending on the version of the card.
> 
> Where is this code?  I don't see any {in,out}[bwl] calls?
> 
> If this were true, we should use io{read,write}{8,16,32}...
> 
> 	Jeff

It is because of new __iomem attributes of readl/writel.
Here are the warnings from the old driver (sparse and gcc)

  CHECK   drivers/net/acenic.c
drivers/net/acenic.c:542:14: warning: cast removes address space of expression
drivers/net/acenic.c:640:16: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:640:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:640:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:640:44: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:640:44:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:640:44:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:642:17: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:642:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:642:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:642:46: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:642:46:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:642:46:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:647:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:647:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:647:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:648:9: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:648:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:648:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:881:12: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:881:12:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:881:12:    got struct ace_regs *regs
drivers/net/acenic.c:924:39: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:924:39:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:924:39:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:925:9: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:925:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:925:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:940:10: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:940:10:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:940:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:942:9: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:942:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:942:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:947:16: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:947:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:947:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:947:44: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:947:44:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:947:44:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:948:9: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:948:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:948:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:949:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:949:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:949:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:951:19: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:951:19:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:951:19:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:960:14: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:960:14:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:960:14:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:969:17: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:969:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:969:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:969:46: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:969:46:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:969:46:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:970:10: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:970:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:970:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:976:27: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:976:27:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:976:27:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:977:29: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:977:29:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:977:29:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1000:48: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1000:48:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1000:48:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1002:9: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1002:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1002:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1025:16: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1025:16:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1025:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1026:16: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1026:16:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1026:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1060:21: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1060:21:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1060:21:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1146:15: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1146:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1146:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1222:25: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1222:25:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1222:25:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1223:32: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1223:32:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1223:32:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1233:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1233:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1233:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1240:26: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1240:26:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1240:26:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:1242:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1242:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1242:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1243:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1243:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1243:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1319:24: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1319:24:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1319:24:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1325:41: warning: incorrect type in argument 2 (different base types)
drivers/net/acenic.c:1325:41:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1325:41:    got unsigned long 
drivers/net/acenic.c:1358:25: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1358:25:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1358:25:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1359:25: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1359:25:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1359:25:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1362:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1362:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1362:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1363:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1363:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1363:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1372:20: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1372:20:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1372:20:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1373:21: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1373:21:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1373:21:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1384:12: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1384:12:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1384:12:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1386:36: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1386:36:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1386:36:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1390:12: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1390:12:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1390:12:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1392:36: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1392:36:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1392:36:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1395:30: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1395:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1395:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1398:33: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1398:33:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1398:33:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1451:15: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1451:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1451:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1453:16: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1453:16:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1453:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1456:29: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1456:29:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1456:29:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1458:30: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1458:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1458:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1460:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1460:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1460:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:745:17: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.h:745:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:745:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1473:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1473:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1473:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1486:19: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1486:19:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1486:19:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1491:16: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1491:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1491:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1491:57: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1491:57:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1491:57:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1492:9: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1492:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1492:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1505:17: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1505:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1505:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1505:45: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1505:45:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1505:45:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1506:10: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1506:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1506:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1518:18: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1518:18:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1518:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1519:12: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1519:12:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1519:12:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1520:14: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1520:14:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1520:14:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1521:10: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1521:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1521:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1565:26: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1565:26:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1565:26:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1567:30: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1567:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1567:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1569:26: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1569:26:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1569:26:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1571:30: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1571:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1571:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1573:27: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1573:27:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1573:27:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1577:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1577:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1577:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1580:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1580:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1580:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1583:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1583:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1583:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1586:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1586:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1586:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1588:33: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1588:33:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1588:33:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1607:42: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1607:42:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1607:42:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1726:16: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1726:16:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1726:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1783:15: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1783:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1783:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1847:16: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1847:16:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1847:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1889:26: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:1889:26:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1889:26:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:1950:21: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:1950:21:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:1950:21:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2087:16: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:2087:16:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2087:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2182:15: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:2182:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2182:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2193:13: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:2193:13:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2193:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2194:9: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:2194:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2194:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2224:18: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:2224:18:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2224:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2229:19: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:2229:19:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2229:19:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2341:35: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:2341:35:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2341:35:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15: warning: incorrect type in argument 1 (different address spaces)
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37: warning: incorrect type in argument 2 (different address spaces)
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15: warning: too many warnings
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:757:14:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:757:14:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:759:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:759:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:759:47:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:759:47:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2437:27:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2437:27:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2438:27:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2438:27:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2439:27:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2439:27:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:771:14:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:771:14:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:773:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:773:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:773:48:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:773:48:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2496:23:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2496:23:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2497:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2497:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2498:21:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2498:21:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2496:23:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2496:23:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2497:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2497:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2498:21:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2498:21:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2496:23:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2496:23:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2497:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2497:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2498:21:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2498:21:    got unsigned int [addressable] *<noident>
drivers/net/acenic.h:745:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.h:745:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2660:34:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2660:34:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2705:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2705:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2709:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2709:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2736:26:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2736:26:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2737:26:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2737:26:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2748:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2748:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2752:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2752:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2791:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2791:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2793:18:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2793:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2838:30:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2838:30:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2840:10:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2840:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:892:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:892:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:894:37:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:894:37:    got unsigned int [addressable] [usertype] *<noident>
drivers/net/acenic.c:897:15:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:897:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2911:38:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2911:38:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2912:31:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2912:31:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2913:32:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2913:32:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2934:42:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2934:42:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2941:26:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2941:26:    got unsigned long 
drivers/net/acenic.c:2965:42:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2965:42:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:2968:20:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2968:20:    got unsigned long 
drivers/net/acenic.c:2993:15:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:2993:15:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3043:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3043:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3045:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3045:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3047:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3047:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3048:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3048:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3052:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3052:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3053:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3053:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3057:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3057:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3058:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3058:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3062:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3062:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3063:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3063:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3074:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3074:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3077:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3077:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3078:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3078:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3087:18:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3087:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3088:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3088:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3093:18:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3093:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3094:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3094:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3098:18:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3098:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3099:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3099:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3110:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3110:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3112:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3112:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3113:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3113:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3117:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3117:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3118:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3118:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3122:18:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3122:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3125:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3125:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3125:53:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3125:53:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3126:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3126:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3138:17:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3138:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3140:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3140:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3141:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3141:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3145:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3145:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3146:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3146:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3150:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3150:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3151:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3151:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3155:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3155:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3156:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3156:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3160:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3160:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3232:18:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3232:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3234:18:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3234:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3235:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3235:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3239:18:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3239:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3240:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3240:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3245:13:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3245:13:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3248:18:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3248:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3250:18:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3250:18:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3251:10:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3251:10:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3256:19:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3256:19:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3257:11:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3257:11:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3264:17:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3264:17:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3265:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3265:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3268:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3268:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3268:52:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3268:52:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3269:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3269:9:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3271:16:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3271:16:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3271:53:    expected void volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3271:53:    got unsigned int [addressable] *<noident>
drivers/net/acenic.c:3272:9:    expected void const volatile [noderef] *addr<asn:2>
drivers/net/acenic.c:3272:9:    got unsigned int [addressable] *<noident>
  CC [M]  drivers/net/acenic.o
drivers/net/acenic.c: In function `ace_init':
drivers/net/acenic.c:1325: warning: passing arg 2 of `writel' makes pointer from integer without a cast
drivers/net/acenic.c: In function `ace_copy':
drivers/net/acenic.c:2941: warning: passing arg 2 of `writel' makes pointer from integer without a cast
drivers/net/acenic.c: In function `ace_clear':
drivers/net/acenic.c:2968: warning: passing arg 2 of `writel' makes pointer from integer without a cast
