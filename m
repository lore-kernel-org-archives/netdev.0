From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v2 3/5] drivers: net: phy: Add MDIO driver
Date: Mon, 6 Jun 2016 10:12:35 -0700
Message-ID: <CAKh23FmaQy8J=f-eyfBeNndz0oT5R0icvwJ3vrw1DMJnj9uv_g@mail.gmail.com>
References: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
	<1464739840-21971-4-git-send-email-isubramanian@apm.com>
	<20160601011148.GD31982@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, patches <patches@apm.com>,
	Matthias Brugger <matthias.bgg@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:36594 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbcFFRMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 13:12:36 -0400
Received: by mail-vk0-f50.google.com with SMTP id c66so54691451vkb.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 10:12:36 -0700 (PDT)
In-Reply-To: <20160601011148.GD31982@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thanks for the review.

On Tue, May 31, 2016 at 6:11 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Tue, May 31, 2016 at 05:10:38PM -0700, Iyappan Subramanian wrote:
>> +static int xgene_mdio_reset(struct xgene_mdio_pdata *pdata)
>> +{
>> +     int ret;
>> +
>> +     if (pdata->mdio_id == XGENE_MDIO_RGMII) {
>> +             if (pdata->dev->of_node) {
>> +                     clk_prepare_enable(pdata->clk);
>> +                     clk_disable_unprepare(pdata->clk);
>> +                     clk_prepare_enable(pdata->clk);
>
> Hi Iyappan
>
> Is that a workaround for a hardware problem? If so, i would suggest
> adding a comment, to stop people submitting a patch simplifying it.

Hardware expects this clock sequence.  I'll add comment as you suggested.

>
>
>> +static int xgene_mdio_probe(struct platform_device *pdev)
>> +{
>> +     struct device *dev = &pdev->dev;
>> +     struct mii_bus *mdio_bus;
>> +     const struct of_device_id *of_id;
>> +     struct resource *res;
>> +     struct xgene_mdio_pdata *pdata;
>> +     void __iomem *csr_addr;
>> +     int mdio_id = 0, ret = 0;
>> +
>
>
>> +     of_id = of_match_device(xgene_mdio_of_match, &pdev->dev);
>> +     if (mdio_id == XGENE_MDIO_RGMII) {
>> +             mdio_bus->read = xgene_mdio_rgmii_read;
>> +             mdio_bus->write = xgene_mdio_rgmii_write;
>> +     } else {
>> +             mdio_bus->read = xgene_xfi_mdio_read;
>> +             mdio_bus->write = xgene_xfi_mdio_write;
>> +     }
>
>> +static const struct of_device_id xgene_mdio_of_match[] = {
>> +     {
>> +             .compatible = "apm,xgene-mdio-rgmii",
>> +             .data = (void *)XGENE_MDIO_RGMII
>> +     },
>> +     {
>> +             .compatible = "apm,xgene-mdio-xfi",
>> +             .data = (void *)XGENE_MDIO_XFI},
>> +     {},
>> +};
>
>
> This all makes me think you should have two separate MDIO drivers, one
> for each compatible string. There is not that much shared code.

I would like to keep the driver consistent with the ethernet driver.
Only the mdio read and write functions are hardware specific, and that
too implemented using function pointers.  Other parts of the code are
shared and much cleaner that way.

>
>     Andrew
