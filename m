From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Thu, 09 Apr 2015 17:58:52 +0200
Message-ID: <5526A1BC.5060609@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <55269BAB.5020201@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <daniel@zonque.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:64548 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755698AbbDIP7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 11:59:01 -0400
In-Reply-To: <55269BAB.5020201@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2015 17:32, Daniel Mack wrote:

> What about the debug registers, such as the one that configures the
> RGMII TX/RX clock delay (4.2.25, 4.2.26). These are indirectly
> addressed, see at803x_config_init().

My dump code:

void mydump(struct phy_device *phydev, int *foo, int *bar)
{
	int i;
	for (i = 0; i < 32; ++i) foo[i] = phy_read(phydev, i);
	for (i = 0; i < 20; ++i) {
		phy_write(phydev, 0x1d, i);
		mdelay(1);
		bar[i] = phy_read(phydev, 0x1e);
	}
}

[    0.738528] IDX=0x01 796d != 7949
[    0.741860] IDX=0x05 c1e1 != 0000
[    0.745191] IDX=0x06 000f != 0004
[    0.748521] IDX=0x0a 3800 != 0000
[    0.751851] IDX=0x11 bc10 != 0012
[    0.755182] IDX=0x13 7400 != 0000
[    0.758513] IDX=0x1b 060e != 0600
[    0.761842] DEBUG REGS
[    0.764211] IDX=0x01 ffd0 != 0032
[    0.767542] IDX=0x02 3f0f != 3110
[    0.770872] IDX=0x03 3fff != 3f00
[    0.774203] IDX=0x0c 0800 != 1801
[    0.777533] IDX=0x0d 0100 != 0000
[    0.780863] IDX=0x0e 0023 != 0040

Differences in debug registers only occur in undocumented registers.
(Only 0x00, 0x05, 0x10, 0x11, 0x12 are documented.)

Regards.
