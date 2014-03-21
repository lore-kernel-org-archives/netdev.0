From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 2/3] net: hisilicon: new hip04 MDIO driver
Date: Fri, 21 Mar 2014 13:27:57 +0800
Message-ID: <CAMj5BkiUUJUEKJJp-5VOHcEXdjxAfSNKK2QZViRCLPs5yqgEzg@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
	<1395132017-15928-3-git-send-email-zhangfei.gao@linaro.org>
	<CAGVrzcY4SBKFfTvjB0TTvgpAOwCt30C6LjYf9e9E4ciMDVmp-w@mail.gmail.com>
	<CAMj5Bkjm3G=K=fqas6VG5NXroofWijN_sc7XGLzT5jVehwTd0Q@mail.gmail.com>
	<CAGVrzcZ4K2gvQ8f=uMTf4+jm29e3FQXL-a-wc9xgumyHpH6+UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:51272 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbaCUF16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 01:27:58 -0400
In-Reply-To: <CAGVrzcZ4K2gvQ8f=uMTf4+jm29e3FQXL-a-wc9xgumyHpH6+UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 1:59 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-03-20 3:53 GMT-07:00 Zhangfei Gao <zhangfei.gao@gmail.com>:
>>>> +static int hip04_mdio_reset(struct mii_bus *bus)
>>>> +{
>>>> +       int temp, err, i;
>>>> +
>>>> +       for (i = 0; i < 2; i++) {
>>>> +               hip04_mdio_write(bus, i, 22, 0);
>>>> +               temp = hip04_mdio_read(bus, i, MII_BMCR);
>>>> +               temp |= BMCR_RESET;
>>>> +               err = hip04_mdio_write(bus, i, MII_BMCR, temp);
>>>> +               if (err < 0)
>>>> +                       return err;
>>>> +       }
>>>> +
>>>> +       mdelay(500);
>>>
>>> This does not look correct, you should iterate over all possible PHYs:
>>> PHY_MAX_ADDR instead of hardcoding the loop to 2.
>>
>> OK, got it.
>> Use 2 is since only have 2 phy in the board, will use PHY_MAX_ADDR instead.
>>>
>>> I think we might want to remove the mdio bus reset callback in general
>>> as the PHY library should already take care of software resetting the
>>> PHY to put it in a sane state, as well as waiting for the appropriate
>>> delay before using, unlike here, where you do not poll for BMCR_RESET
>>> to be cleared by the PHY.
>>>
>> Do you mean will move BMCR_RESET to common code, that's would be great.
>> The mdio_reset is added here to get phy_id, otherwise the phy_id can
>> not be read as well as detection.
>
> Oh I see, thanks for mentioning that, this is not properly covered
> here today as we need to get the PHY id before we assign it a
> phy_device structure, let me cook a patch for this.
> --

Should I keep hip04_mdio_reset in the next submit or remove it directly?

Thanks
