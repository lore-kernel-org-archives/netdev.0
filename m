From: Martin Capitanio <c4p7n@capitanio.org>
Subject: Re: [PATCH 2/2] r8169: checks against wrong mac addresse init
Date: Sat, 18 Oct 2008 01:52:28 +0200
Message-ID: <1224287548.24161.90.camel@marvin>
References: <20081016214555.GA27208@electric-eye.fr.zoreil.com>
	 <20081016214808.GC27208@electric-eye.fr.zoreil.com>
	 <1224265672.17605.27.camel@marvin>
	 <20081017200114.GA25222@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	"J.A." =?ISO-8859-1?Q?Magall=F3n?= <jamagallon@ono.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:58093 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606AbYJQXx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 19:53:29 -0400
In-Reply-To: <20081017200114.GA25222@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-10-17 at 22:01 +0200, Francois Romieu wrote:
> Martin Capitanio <c4p7n@capitanio.org> :
> [...]
> > Please take a look at the realtek r8101_n aka RealTek RTL8101E,
> > RTL8102E(L) code. Only CFG_METHOD_1, CFG_METHOD_2
> > and #(ioaddr, 0x00) == 0x8128 are here allowed to EEPROM access.
> 
> So Realtek's 810x driver eeprom code targets the 8101Eb and the
> 8101Ec only. It does not include Ivan's 8102el.

So it seems ;)
RTL_W8(Cfg9346, Cfg9346_AMMO);
        mdelay(15);

and here they arm/unarm vpd:

static int
rtl8169_eeprom_read(struct net_device *dev, u32 *eeprom_cont, int eeprom_size)
{
	struct rtl8169_private *tp = netdev_priv(dev);
	void __iomem *ioaddr = tp->mmio_addr;
	int i;
	unsigned int read_addr;

	RTL_W8(Cfg9346, Cfg9346_Unlock);
	RTL_W8(Config1, RTL_R8(Config1) | VPDEnable);
	RTL_W8(Cfg9346, Cfg9346_Lock);

	for (i = 0, read_addr = 0; i < eeprom_size / 4; i++)
		*(eeprom_cont + i) = rtl8169_vpd_read(dev, read_addr + i * 4);

	RTL_W8(Cfg9346, Cfg9346_Unlock);
	RTL_W8(Config1, RTL_R8(Config1) & ~VPDEnable);
	RTL_W8(Cfg9346, Cfg9346_Lock);

	return 0;
}

