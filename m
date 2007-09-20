From: Chris Snook <csnook@redhat.com>
Subject: Re: netif_rx will not free skb when I use ftp in kernel 2.6.22/2.6.21
Date: Thu, 20 Sep 2007 00:16:39 -0400
Message-ID: <46F1F427.3060303@redhat.com>
References: <31156967.830941190260738334.JavaMail.coremail@bj126app89.126.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=x-gbk;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: =?x-gbk?Q?=D5=C5=B7=C9?= <zhangandfei@126.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737AbXITERH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 00:17:07 -0400
In-Reply-To: <31156967.830941190260738334.JavaMail.coremail@bj126app89.126.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=D5=C5=B7=C9 wrote:
> Dear netdev,
> =20
> I have one problem with my NIC driver: whenever I use =20
> netif_receive_skb(skb) or netif_rx(skb) to indicate received packet, =
=20
> iperf does work, but ftp does not work, because the kernel seemes not=
=20
> kfree_skb(skb) when I use ftp.  What=A1=AFs wrong with my NIC  driver=
? Any=20
> suggestions will be appreciated. Thanks in advance.
> =20
> When I use iperf to test my NIC driver, it seems okay. When I use ftp=
,=20
> ftp client in kernel 2.6.22 and ftp server is ServUftp at windows2000=
,=20
> it does work too. But, When I use windows2003 server and its containe=
d=20
> ftp server, my NIC driver can get file from that ftp server until the=
=20
> memory is used out.  When I get 3G file, then 3G memory will be used =
and=20
> not freed.
> =20
> The source code is at :=20
> http://sourceforge.krugle.com/kse/files?project=3D%22Attansic%20L1%20=
Gigabit%20Ethernet%20driver%22=20
> <http://sourceforge.krugle.com/kse/files?project=3D%22Attansic%20L1%2=
0Gigabit%20Ethernet%20driver%22>
> Please check the function at_clean_rx_irq() and at_alloc_rx_buffers()=
 in=20
> file at_main.c.
> I dev_alloc_skb() and pci_map_single() skb in function=20
> at_alloc_rx_buffers(), pci_unmap_page() and netif_rx() in function=20
> at_clean_rx_irq(), CONFIG_AT_NAPI is not defined.
> =20
> Thank csnook.
> =20
> Best Regards,
> Fei Zhang

Okay, I didn't know you were talking about the atl1 driver.  Are you=20
using the
in-tree driver in 2.6.22, or the pre-merge driver on sourceforge, or th=
e=20
vendor
driver from Attansic/Atheros?

Also, can you test this again using the latest 2.6.23-rc7 kernel, with=20
the atl1 driver
included in that kernel?

	-- Chris

> =D4=DA2007-09-20=A3=AC"Chris Snook" <csnook@redhat.com> =D0=B4=B5=C0=A3=
=BA
>=20
>     =D5=C5=B7=C9 wrote:
>     > Dear csnook,
>     > I have one problem in my NIC driver: whenever I use =20
>     > netif_receive_skb(skb) or netif_rx(skb) to indicate received pa=
cket,=20
>     > iperf does work, but ftp does not work,
>     > because the kernel seemes not kfree_skb(skb).  What=A1=AFs wron=
g with my NIC=20
>     > driver? Any suggestions will be appreciated. Thanks in advance.
>     > Best wishes,
>     > Fei Zhang
>     > =20
>     > Kernel v2.6.22
>     > Cpu : amd64
>     > Memory: 4G
>=20
>     I'm going to need way more information than that.  I'm also not c=
ertain I'm the=20
>     best person to answer the question.  I suggest asking the questio=
n again, with a=20
>     lot more info, to netdev@vger.kernel.org.  You're welcome to CC m=
e as well.=20
>     Please also post a link to the driver source so we can see what e=
xactly you're=20
>     doing.
>=20
>     	-- Chris
