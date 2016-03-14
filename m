From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCHv3 (net.git) 2/2] stmmac: fix MDIO settings
Date: Mon, 14 Mar 2016 10:28:14 +0100
Message-ID: <56E6842E.1040103@st.com>
References: <1457703196-15008-1-git-send-email-peppe.cavallaro@st.com> <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com> <CAG374jDMk3z0rn-eMfRWiw7FUvN_26yjsVc340zvQPFq=XxuLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, Dinh Nguyen <dinh.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Phil Reid <preid@electromag.com.au>
To: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:35265 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964876AbcCNJ2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 05:28:45 -0400
In-Reply-To: <CAG374jDMk3z0rn-eMfRWiw7FUvN_26yjsVc340zvQPFq=XxuLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/14/2016 10:14 AM, Gabriel Fernandez wrote:
> Hi Peppe,
>
> Just one remark below
>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> index 6a52fa1..d2322e9 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>
> [snip]
>
>> +static bool stmmac_dt_phy(struct plat_stmmacenet_data *plat,
>> +                         struct device_node *np, struct device *dev)
>> +{
>> +       bool ret = true;
>> +
>> +       /* If phy-handle property is passed from DT, use it as the PHY */
>> +       plat->phy_node = of_parse_phandle(np, "phy-handle", 0);
>> +       if (plat->phy_node)
>> +               dev_dbg(dev, "Found phy-handle subnode\n");
>> +
>> +       /* If phy-handle is not specified, check if we have a fixed-phy */
>> +       if (!plat->phy_node && of_phy_is_fixed_link(np)) {
>> +               if ((of_phy_register_fixed_link(np) < 0))
>> +                       return -ENODEV;
>> +
> stmmac_dt_phy() function should return a Boolean

Thx Gabriel, I will fix return value in V4.

peppe

>
>
> Best Regards.
>
> Gabriel
>
>
