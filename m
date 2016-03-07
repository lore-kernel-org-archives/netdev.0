From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 7 Mar 2016 16:46:52 +0100
Message-ID: <56DDA26C.3050301@suse.de>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
 <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com>
 <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	=?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Alexandre TORGUE <alexandre.torgue@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45761 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbcCGPqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 10:46:55 -0500
In-Reply-To: <56DD99A4.5030004@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

Am 07.03.2016 um 16:09 schrieb Giuseppe CAVALLARO:
> On 3/7/2016 3:27 PM, Andreas F=E4rber wrote:
>> Indeed, reverting Gabriel's commit fixes the observed error messages
[...]
>> However, I am unable to ping any hosts on the network now.
>=20
> hmm, this could be another problem. I wonder if you can
> check which recent patch is introducing the problem on ARM64.
> For example if this depends on Oct_2015 update.

I've had success reverting drivers/net/ethernet/stmicro/ up to and
including "stmmac: first frame prep at the end of xmit routine", i.e.
top 7 commits.

http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/=
drivers/net/ethernet/stmicro?id=3D0e80bdc9a72df3b31a9fc2012102a6cc8d664=
e93

> If you share some logs to me I can take a look at them.
> Then we can try to check if the problem in on rx or tx path.
> I also ask you yo check the axi settings.

On the reverted (good) branch I see in dmesg:

[  +0.001100] rk_gmac-dwmac ff290000.ethernet: Looking up phy-supply
from device tree
[  +0.000030] rk808 0-001b: Looking up vcc12-supply from device tree
[  +0.000013] vcc_lan: supplied by vcc_io
[  +0.000120] rk_gmac-dwmac ff290000.ethernet: clock input or output?
(input).
[  +0.000010] rk_gmac-dwmac ff290000.ethernet: TX delay(0x30).
[  +0.000007] rk_gmac-dwmac ff290000.ethernet: RX delay(0x10).
[  +0.000014] rk_gmac-dwmac ff290000.ethernet: init for RGMII
[  +0.000104] rk_gmac-dwmac ff290000.ethernet: clock input from PHY
[  +0.005099] rk_gmac-dwmac ff290000.ethernet: no reset control found
[  +0.000007] stmmac - user ID: 0x10, Synopsys ID: 0x35
[  +0.000002]  Ring mode enabled
[  +0.000006]  DMA HW capability register supported
[  +0.000000]  Normal descriptors
[  +0.000004]  RX Checksum Offload Engine supported (type 2)
[  +0.000002]  TX Checksum insertion supported
[  +0.000002]  Wake-Up On Lan supported
[  +0.000052]  Enable RX Mitigation via HW Watchdog Timer
[  +0.000683] rk_gmac-dwmac ff290000.ethernet eth0: No MDIO subnode fou=
nd
[  +0.000124] of_get_named_gpiod_flags: can't parse 'snps,reset-gpio'
property of node '/ethernet@ff290000[0]'
[  +0.004219] libphy: stmmac: probed
[  +0.000010] eth0: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) active
[  +0.000005] eth0: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)

[  +0.881011] eth0: device MAC address 4a:78:dd:10:b3:17
[  +4.003065] rk_gmac-dwmac ff290000.ethernet eth0: Link is Up -
1Gbps/Full - flow control rx/tx

The MAC address is random, changing each time. Otherwise there's no log
difference I spot to the pre-Gabriel broken state.

If you need more info, let me know where to find it.

Thanks,
Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG N=FC=
rnberg)
