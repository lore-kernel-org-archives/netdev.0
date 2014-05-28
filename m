From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net-next] net: stmmac: Handle different error codes from platform_get_irq_byname
Date: Wed, 28 May 2014 08:30:35 -0500
Message-ID: <CAL_JsqKfmg+MBazWXC4oe_mn3Uw_GSJf+oiYS3NsT02baH9GeA@mail.gmail.com>
References: <1401166194-19085-1-git-send-email-wens@csie.org>
	<CAL_Jsq+dkdYsw+dQc_tuTT5FJ9QWk2cX7Lq4UiGEH2UqmB24gg@mail.gmail.com>
	<CAGb2v66W4EkUkxEdE+7MQp6pYue_SycpXvktHhwr-tSEXXJ62Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Kevin Hilman <khilman@linaro.org>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f178.google.com ([209.85.128.178]:46396 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767AbaE1Nag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 09:30:36 -0400
Received: by mail-ve0-f178.google.com with SMTP id sa20so12350678veb.23
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 06:30:35 -0700 (PDT)
In-Reply-To: <CAGb2v66W4EkUkxEdE+7MQp6pYue_SycpXvktHhwr-tSEXXJ62Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2014 at 1:44 AM, Chen-Yu Tsai <wens@csie.org> wrote:
> On Wed, May 28, 2014 at 8:58 AM, Rob Herring <robh@kernel.org> wrote:
>> On Mon, May 26, 2014 at 11:49 PM, Chen-Yu Tsai <wens@csie.org> wrote:
>>> The following patch moved device tree interrupt resolution into
>>> platform_get_irq_byname:
>>>
>>>   ad69674 of/irq: do irq resolution in platform_get_irq_byname()
>>>
>>> As a result, the function no longer only return -ENXIO on error.
>>> This breaks DT based probing of stmmac, as seen in test runs of
>>> linux-next next-20140526 cubie2-sunxi_defconfig:

[...]

>>>         priv->lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
>>> +       if (priv->lpi_irq < 0) {
>>
>> You don't need this if.
>
> stmmac core driver checks lpi_irq != -ENXIO for valid interrupt.
> Might as well change that check to  lpi_irq >= 0.
> (0 is a valid interrupt, correct?)

No. NO_IRQ is defined to 0 (preferred) or -1 depending on the arch.
You should be testing for "> 0" for valid irq rather than only ENXIO.

My comment still stands. If lpi_irq is already <0, then there is no
reason to set it to -ENXIO (again). If there are other error codes
returned, changing the error code is not good practice.

> Interestingly, stmmac_pci never sets lpi_irq, there might be a glitch
> there.

I believe they would have to be combined to a single interrrupt for PCI.

Rob
