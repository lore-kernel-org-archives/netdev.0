From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for
 T4240-R1.0-R2.0
Date: Mon, 14 Mar 2016 17:45:43 +0000
Message-ID: <DB5PR0401MB19286B2D23D07F5C60DB799D91880@DB5PR0401MB1928.eurprd04.prod.outlook.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
 <1457518131-11339-6-git-send-email-yangbo.lu@nxp.com>
 <4947024.WeMycs2fID@wuerfel>
 <HE1PR04MB0889CE4742B92461A925B9C4F8880@HE1PR04MB0889.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "ulf.hansson@linaro.org" <ulf.hansson@linaro.org>,
 Zhao Qiang <qiang.zhao@freescale.com>, Russell King <linux@arm.linux.org.uk>,
 Bhupesh Sharma <bhupesh.sharma@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Joerg Roedel <joro@8bytes.org>, Kumar Gala <galak@codeaurora.org>,
 "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Yang-Leo Li <leoyang.li@nxp.com>,
 "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, Rob
 Herring <robh+dt@kernel.org>,
 "linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
 Claudiu Manoil <claudiu.manoil@freescale.com>,
 Santosh Shilimkar <ssantosh@kernel.org>, Xiaobo Xie <xiaobo.xie@nxp.com>,
 "linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.
To: Yangbo Lu <yangbo.lu@nxp.com>, Arnd Bergmann <arnd@arndb.de>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 03/14/2016 02:29 AM, Yangbo Lu wrote:
>> -----Original Message-----
>> From: Arnd Bergmann [mailto:arnd@arndb.de]
>> Sent: Monday, March 14, 2016 6:26 AM
>> To: linuxppc-dev@lists.ozlabs.org
>> Cc: Yangbo Lu; devicetree@vger.kernel.org; linux-arm-
>> kernel@lists.infradead.org; linux-kernel@vger.kernel.org; linux-
>> clk@vger.kernel.org; linux-i2c@vger.kernel.org; iommu@lists.linux-
>> foundation.org; netdev@vger.kernel.org; linux-mmc@vger.kernel.org;
>> ulf.hansson@linaro.org; Zhao Qiang; Russell King; Bhupesh Sharma; Joerg
>> Roedel; Santosh Shilimkar; Scott Wood; Rob Herring; Claudiu Manoil; Kumar
>> Gala; Yang-Leo Li; Xiaobo Xie
>> Subject: Re: [v6, 5/5] mmc: sdhci-of-esdhc: fix host version for T4240-
>> R1.0-R2.0
>>
>> On Wednesday 09 March 2016 18:08:51 Yangbo Lu wrote:
>>> @@ -567,10 +580,20 @@ static void esdhc_init(struct platform_device
>> *pdev, struct sdhci_host *host)
>>>         struct sdhci_pltfm_host *pltfm_host;
>>>         struct sdhci_esdhc *esdhc;
>>>         u16 host_ver;
>>> +       u32 svr;
>>>
>>>         pltfm_host =3D sdhci_priv(host);
>>>         esdhc =3D sdhci_pltfm_priv(pltfm_host);
>>>
>>> +       fsl_guts_init();
>>> +       svr =3D fsl_guts_get_svr();
>>> +       if (svr) {
>>> +               esdhc->soc_ver =3D SVR_SOC_VER(svr);
>>> +               esdhc->soc_rev =3D SVR_REV(svr);
>>> +       } else {
>>> +               dev_err(&pdev->dev, "Failed to get SVR value!\n");
>>> +       }
>>> +
>>
>> This makes the driver non-portable. Better identify the specific
>> workarounds based on the compatible string for this device, or add a
>> boolean DT property for the quirk.
>>
>> 	Arnd
> =

> [Lu Yangbo-B47093] Hi Arnd, we did have a discussion about using DTS in v=
1 before.
> https://patchwork.kernel.org/patch/6834221/
> =

> We don=92t have a separate DTS file for each revision of an SOC and if we=
 did, we'd constantly have people using the wrong one.
> In addition, the device tree is stable ABI and errata are often discovere=
d after device tree are deployed.
> See the link for details.
> =

> So we decide to read SVR from the device-config/guts MMIO block other tha=
n using DTS.
> Thanks.

Also note that this driver is already only for fsl-specific hardware,
and it will still work even if fsl_guts doesn't find anything to bind to
-- it just wouldn't be able to detect errata based on SVR in that case.

-Scott
