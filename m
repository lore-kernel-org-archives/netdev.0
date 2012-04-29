From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH 02/10] atl1c: add PHY link event(up/down) patch
Date: Sun, 29 Apr 2012 10:07:17 +0000
Message-ID: <157393863283F442885425D2C454285623D5FCD8@nasanexd02a.na.qualcomm.com>
References: <1335578325-21326-1-git-send-email-xiong@qca.qualcomm.com>
 <1335578325-21326-3-git-send-email-xiong@qca.qualcomm.com>
 <201204281924.20714.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:60504 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab2D2KHS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 06:07:18 -0400
In-Reply-To: <201204281924.20714.florian@openwrt.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +struct atl1c_platform_patch {
> > +	u16 pci_vid;
> > +	u16 pci_did;
> > +	u8  pci_revid;
> > +	u16 subsystem_vid;
> > +	u16 subsystem_did;
> > +	u32 patch_flag;
> > +#define ATL1C_LINK_PATCH	0x1
> > +};
> > +static struct atl1c_platform_patch plats[] = {
> 
> This should be static const.

Thanks. It is.

> 
> > +{0x1969, 0x2060, 0xC1, 0x1019, 0x8152, 0x1}, {0x1969, 0x2060, 0xC1,
> > +0x1019, 0x2060, 0x1}, {0x1969, 0x2060, 0xC1, 0x1019, 0xE000, 0x1},
> > +{0x1969, 0x2062, 0xC0, 0x1019, 0x8152, 0x1}, {0x1969, 0x2062, 0xC0,
> > +0x1019, 0x2062, 0x1}, {0x1969, 0x2062, 0xC0, 0x1458, 0xE000, 0x1},
> > +{0x1969, 0x2062, 0xC1, 0x1019, 0x8152, 0x1}, {0x1969, 0x2062, 0xC1,
> > +0x1019, 0x2062, 0x1}, {0x1969, 0x2062, 0xC1, 0x1458, 0xE000, 0x1},
> > +{0x1969, 0x2062, 0xC1, 0x1565, 0x2802, 0x1}, {0x1969, 0x2062, 0xC1,
> > +0x1565, 0x2801, 0x1}, {0x1969, 0x1073, 0xC0, 0x1019, 0x8151, 0x1},
> > +{0x1969, 0x1073, 0xC0, 0x1019, 0x1073, 0x1}, {0x1969, 0x1073, 0xC0,
> > +0x1458, 0xE000, 0x1}, {0x1969, 0x1083, 0xC0, 0x1458, 0xE000, 0x1},
> > +{0x1969, 0x1083, 0xC0, 0x1019, 0x8151, 0x1}, {0x1969, 0x1083, 0xC0,
> > +0x1019, 0x1083, 0x1}, {0x1969, 0x1083, 0xC0, 0x1462, 0x7680, 0x1},
> > +{0x1969, 0x1083, 0xC0, 0x1565, 0x2803, 0x1}, {0},
> 
> Since patch_flag is always set to 0x1, just remove it, if you find a matching entry,
> apply the patch. Vendor ID is always the same, remove it as well.
> 
Thanks, Florain.
It's reasonable to remove Vendor ID since this driver only support one dedicated VID.
But for patch_flag, I'm afraid it could be used for other bug/issue, though we found 
One link issue (=flag bit 0) till now. Otherwise, I will not use ATL1C_LINK_PATCH in function
atl1c_patch_assign.

> Looking at the supported PCI devices table, this patching table is applicable to all
> Atheros PCI device id and none of the Attansic PCI device id, this suggests that

Atl1c driver only supports Atheros PCI device id, Attansic device id is supported by 
Atl1e & atlx.

> your table should be reversed, and you should only list the devices *not*
> needing the patch, this should make the lookup code smaller.
> 

It's almost impossible, there is over 200+ modules sold out, the issue is related to PCB layout,
The total percentage of issue modules is much lower than the normal.



B.R.
Xiong
