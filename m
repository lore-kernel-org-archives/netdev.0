From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Thu, 24 Apr 2008 17:21:25 -0300
Message-ID: <4810EBC5.4060508@linux.vnet.ibm.com>
References: <20080414180338.GA18335@google.com> <20080415.003153.30044057.davem@davemloft.net> <cc96a5040804151007q6008355cl2cc85242b81f3918@mail.gmail.com> <20080415.192330.29185957.davem@davemloft.net> <4810CEB6.60707@linux.vnet.ibm.com> <20080424190148.GA19511@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thockin@google.com,
	netdev@vger.kernel.org, jeff@garzik.org, joe@perches.com,
	nil@google.com, matthew@wil.cx
To: Mandeep Singh Baines <msb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:53908 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761468AbYDXUVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 16:21:50 -0400
Received: from mailhub3.br.ibm.com (unknown [9.18.232.110])
	by igw3.br.ibm.com (Postfix) with ESMTP id 570213900AF
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 17:08:12 -0300 (BRST)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3OKLjoq1892526
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 17:21:47 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3OKLUmq007447
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 17:21:34 -0300
In-Reply-To: <20080424190148.GA19511@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mandeep,

Mandeep Singh Baines wrote:
> I suspect you may have mis-applied the patch. The patch changes both
> set_eeprom and get_eeprom. I think you may have modified get_eeprom t=
o call
> ops->set_eeprom instead of ops->get_eeprom. If not, please send me et=
htool.c
> and tg3.c and I can take a look.

Well, IMHO the patch is correctly applied as I could see. I just got th=
e=20
David's tree and run a diff between the ethtool.c files (from David's=20
tree and mine), and I get the following differences. Note that I just=20
add a printk() there to "debug" what was going on.

static int ethtool_get_eeprom(struct net_device *dev, void __user *user=
addr)
 {
        struct ethtool_eeprom eeprom;
-       const struct ethtool_ops *ops =3D dev->ethtool_ops;
+       struct ethtool_ops *ops =3D dev->ethtool_ops;
        void __user *userbuf =3D useraddr + sizeof(eeprom);
        u32 bytes_remaining;
        u8 *data;
        int ret =3D 0;

+       printk("<1> ethtool_get_eeprom()\n");
        if (!ops->get_eeprom || !ops->get_eeprom_len)
                return -EOPNOTSUPP;

@@ -330,12 +330,13 @@ static int ethtool_get_eeprom(struct net
 static int ethtool_set_eeprom(struct net_device *dev, void __user=20
*useraddr)
 {
        struct ethtool_eeprom eeprom;
-       const struct ethtool_ops *ops =3D dev->ethtool_ops;
+       struct ethtool_ops *ops =3D dev->ethtool_ops;
        void __user *userbuf =3D useraddr + sizeof(eeprom);
        u32 bytes_remaining;
        u8 *data;
        int ret =3D 0;

+       printk("<1> ethtool_set_eeprom()\n");
        if (!ops->set_eeprom || !ops->get_eeprom_len)
                return -EOPNOTSUPP;


The patched ethtool.c is at  http://rafb.net/p/fWXNwk28.html and tg3.c=20
is at http://rapidshare.com/files/110139941/tg3.c.html

--
Breno Leit=C3=A3o
leitao@linux.vnet.ibm.com
