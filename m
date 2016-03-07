From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 7 Mar 2016 16:52:53 +0100
Message-ID: <56DDA3D5.3090209@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
 <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com>
 <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
 <56DDA26C.3050301@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?windows-1252?Q?Heiko_St=FCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Gabriel Fernandez <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Fabrice GASNIER <fabrice.gasnier-qxv4g6HH51o@public.gmane.org>,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
To: =?windows-1252?Q?Andreas_F=E4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <56DDA26C.3050301-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/7/2016 4:46 PM, Andreas F=E4rber wrote:
> Hi Peppe,
>
> Am 07.03.2016 um 16:09 schrieb Giuseppe CAVALLARO:
>> On 3/7/2016 3:27 PM, Andreas F=E4rber wrote:
>>> Indeed, reverting Gabriel's commit fixes the observed error messages
> [...]
>>> However, I am unable to ping any hosts on the network now.
>>
>> hmm, this could be another problem. I wonder if you can
>> check which recent patch is introducing the problem on ARM64.
>> For example if this depends on Oct_2015 update.
>
> I've had success reverting drivers/net/ethernet/stmicro/ up to and
> including "stmmac: first frame prep at the end of xmit routine", i.e.
> top 7 commits.

Andreas, I will check it and let you know asap.

>
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/dr=
ivers/net/ethernet/stmicro?id=3D0e80bdc9a72df3b31a9fc2012102a6cc8d664e93
>
>> If you share some logs to me I can take a look at them.
>> Then we can try to check if the problem in on rx or tx path.
>> I also ask you yo check the axi settings.
>
> On the reverted (good) branch I see in dmesg:
>
> [  +0.001100] rk_gmac-dwmac ff290000.ethernet: Looking up phy-supply
> from device tree
> [  +0.000030] rk808 0-001b: Looking up vcc12-supply from device tree
> [  +0.000013] vcc_lan: supplied by vcc_io
> [  +0.000120] rk_gmac-dwmac ff290000.ethernet: clock input or output?
> (input).
> [  +0.000010] rk_gmac-dwmac ff290000.ethernet: TX delay(0x30).
> [  +0.000007] rk_gmac-dwmac ff290000.ethernet: RX delay(0x10).
> [  +0.000014] rk_gmac-dwmac ff290000.ethernet: init for RGMII
> [  +0.000104] rk_gmac-dwmac ff290000.ethernet: clock input from PHY
> [  +0.005099] rk_gmac-dwmac ff290000.ethernet: no reset control found
> [  +0.000007] stmmac - user ID: 0x10, Synopsys ID: 0x35
> [  +0.000002]  Ring mode enabled
> [  +0.000006]  DMA HW capability register supported
> [  +0.000000]  Normal descriptors
> [  +0.000004]  RX Checksum Offload Engine supported (type 2)
> [  +0.000002]  TX Checksum insertion supported
> [  +0.000002]  Wake-Up On Lan supported
> [  +0.000052]  Enable RX Mitigation via HW Watchdog Timer
> [  +0.000683] rk_gmac-dwmac ff290000.ethernet eth0: No MDIO subnode found
> [  +0.000124] of_get_named_gpiod_flags: can't parse 'snps,reset-gpio'
> property of node '/ethernet@ff290000[0]'
> [  +0.004219] libphy: stmmac: probed
> [  +0.000010] eth0: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) active
> [  +0.000005] eth0: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)
>
> [  +0.881011] eth0: device MAC address 4a:78:dd:10:b3:17
> [  +4.003065] rk_gmac-dwmac ff290000.ethernet eth0: Link is Up -
> 1Gbps/Full - flow control rx/tx
>
> The MAC address is random, changing each time. Otherwise there's no log
> difference I spot to the pre-Gabriel broken state.

ok
>
> If you need more info, let me know where to find it.

no it's ok at this stage.

>
> Thanks,

welcome

> Andreas

Regards
peppe
