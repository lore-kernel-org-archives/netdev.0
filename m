From: Angelo Dureghello <angelo70@gmail.com>
Subject: Re: Micrel KSZ8031 - phy link missing
Date: Fri, 10 Oct 2014 12:54:02 +0200
Message-ID: <5437BACA.1000201@gmail.com>
References: <915054555B5659448ACF8A70E114824D0163C79016@Exchange2010.kamstrup.dk> <5437A7A2.3020700@gmail.com> <915054555B5659448ACF8A70E114824D0163C7A77B@Exchange2010.kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Bruno Thomsen <bth@kamstrup.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34619 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbaJJKyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 06:54:07 -0400
Received: by mail-wg0-f41.google.com with SMTP id b13so3622648wgh.24
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 03:54:04 -0700 (PDT)
In-Reply-To: <915054555B5659448ACF8A70E114824D0163C7A77B@Exchange2010.kamstrup.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Thomsen,

thanks for the prompt help,
well i am setting up that clock pin in my board.c, as

#define DA850_EVM_PHY_ID        "davinci_mdio-0:00"
#define DA850_MII_MDIO_CLKEN_PIN    GPIO_TO_PIN(2, 6)

  ret = davinci_cfg_reg(DA850_GPIO2_6);
     if (ret)
         pr_warn("%s:GPIO(2,6) mux setup failed\n", __func__);

     ret = gpio_request(DA850_MII_MDIO_CLKEN_PIN, "mdio_clk_en");
     if (ret) {
         pr_warn("Cannot open GPIO %d\n", DA850_MII_MDIO_CLKEN_PIN);
         return ret;
     }

     /* Enable/Disable MII MDIO clock */
     gpio_direction_output(DA850_MII_MDIO_CLKEN_PIN, rmii_en);


Probably it's me that i am doing something illegal, i explain:

I am moving from a 3.5.1 to a 3.17 kernel, but have a special board.c 
startup file i cannot convert into DT easily.
So i am booting using old way (board.c).
Now, new kernels have "pinctrl" that probably jump over my gpio setting 
later in the boot, is it possible ?

Thanks
Angelo




On 10/10/2014 12:31, Bruno Thomsen wrote:
> Hey
>
>> i still have the issue after patching kernel 3.17.
>> ...
>> I am using RMII in my custom board, don't know if it makes any difference.
> What RMII clock source do you use? MAC, PHY or external?
>
> If your MAC output the RMII clock you need to enable MICREL_PHY_50MHZ_CLK flag in phydev->dev_flags.
>
>
> Venlig hilsen / Best regards
>
> Kamstrup A/S <http://www.kamstrup.dk>
> Bruno Thomsen
> Development engineer
> Technology
>
> Kamstrup A/S
> Industrivej 28
> DK-8660 Skanderborg
> Tel:	 +45 89 93 10 00	
> Fax:	 +45 89 93 10 01	
> Dir:	 +45 89 93 13 94	
> E-mail:	 bth@kamstrup.dk	
> Web:	 www.kamstrup.dk
