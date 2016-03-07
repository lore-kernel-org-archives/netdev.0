From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 7 Mar 2016 16:09:24 +0100
Message-ID: <56DD99A4.5030004@st.com>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
 <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com>
 <56DD8FBE.9010200@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 LAKML <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 =?windows-1252?Q?Heiko_St=FCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
To: =?windows-1252?Q?Andreas_F=E4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>, Gabriel Fernandez
 <gabriel.fernandez-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <56DD8FBE.9010200-l3A5Bk7waGM@public.gmane.org>
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

Hi Andreas

On 3/7/2016 3:27 PM, Andreas F=E4rber wrote:
> Hello Giuseppe,
>
> Am 07.03.2016 um 14:26 schrieb Giuseppe CAVALLARO:
>> On 3/7/2016 1:35 PM, Andreas F=E4rber wrote:
>>> Am 07.03.2016 um 13:24 schrieb Heiko St=FCbner:
>>>> Am Montag, 7. M=E4rz 2016, 13:17:54 schrieb Andreas F=E4rber:
>>>>> Am 06.03.2016 um 20:53 schrieb Andreas F=E4rber:
>>>>>> On next-20160304 the GMAC seems to have regressed, it no longer
>>>>>> finds the
>>>>>> PHY:
>>>>>>
>>>>>> libphy: PHY stmmac-0:ffffffff not found
>>
>> snps,phy-addr is not correct. Can you check it?
>
> It was never set:
>
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/arc=
h/arm64/boot/dts/rockchip/rk3368.dtsi#n436
>
> https://github.com/afaerber/linux/blob/96c5b5fd395fee5713755e93e677fb011c=
b9ddc0/arch/arm64/boot/dts/rockchip/rk3368-geekbox.dts#L114
>
>> In the stmmac_mdio if this is not passed as parameter the bus should
>> be scanned and the first IDs found should select the right address.
>> I suppose in your box there is a real transceiver, so maybe the patch
>> from Gabriel is not actually necessary.
>
> On the GeekBox module there's an RTL8211E phy.
>
> Indeed, reverting Gabriel's commit fixes the observed error messages:
>
> rk_gmac-dwmac ff290000.ethernet eth0: Link is Up - 1Gbps/Full - flow
> control rx/tx

so this means that the phy is found and the link auto-negotiated.

Gabriel, it sounds that the patch solved a regression you found on
a configuration where the MAC dialogs with a switch but it breaks the
setup with use a std transceiver.

> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/dr=
ivers/net/ethernet/stmicro?id=3D88f8b1bb41c6208f81b6a480244533ded7b59493
>
> However, I am unable to ping any hosts on the network now.

hmm, this could be another problem. I wonder if you can
check which recent patch is introducing the problem on ARM64.
For example if this depends on Oct_2015 update.

If you share some logs to me I can take a look at them.
Then we can try to check if the problem in on rx or tx path.
I also ask you yo check the axi settings.

Let me know

Regards
peppe

>
> Regards,
> Andreas
>
>>>>>> eth0: Could not attach to PHY
>>>>>> stmmac_open: Cannot attach to PHY (error: -19)
>>>>>
>>>>> Still with us in next-20160307. CC'ing stmmac maintainers.
>>
>> peppe
>>
>>>>
>>>> do you remember from what revision you rebased away from, when it was
>>>> still
>>>> working (as a known-good state)?
>>>
>>> Hm, next-20160111 possibly... leaving all the 5 days and 4 days ago
>>> changes as candidates ("stmmac: share reset function between dwmac100
>>> and dwmac1000" .. "stmmac: Fix 'eth0: No PHY found' regression").
>
