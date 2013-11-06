From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Tue, 5 Nov 2013 16:16:08 -0800
Message-ID: <CAGVrzcYzBtDcxYXDopOJn_=vW_58SFs9y0uKeGNB9TDPh6J4wg@mail.gmail.com>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
 <1383629471-16979-3-git-send-email-alistair@popple.id.au> <CAGVrzcZQ26kbim2piOwrvpyOcSaTET5da7Yh4GWv+erfuOBDhQ@mail.gmail.com>
 <81419762.0SyAdYsUqu@mexican>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alistair Popple <alistair@popple.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:44940 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698Ab3KFAQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 19:16:49 -0500
Received: by mail-pa0-f44.google.com with SMTP id fb1so9731332pad.31
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 16:16:48 -0800 (PST)
In-Reply-To: <81419762.0SyAdYsUqu@mexican>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/11/5 Alistair Popple <alistair@popple.id.au>:
> On Tue, 5 Nov 2013 10:47:22 Florian Fainelli wrote:
>> [snip]
>>
>> > +/* RGMII bridge supports only GMII/TBI and RGMII/RTBI PHYs */
>> > +static inline int rgmii_valid_mode(int phy_mode)
>> > +{
>> > +       return  phy_mode == PHY_MODE_GMII ||
>> > +               phy_mode == PHY_MODE_MII ||
>> > +               phy_mode == PHY_MODE_RGMII ||
>> > +               phy_mode == PHY_MODE_TBI ||
>> > +               phy_mode == PHY_MODE_RTBI;
>> > +}
>> > +
>> > +static inline const char *rgmii_mode_name(int mode)
>> > +{
>> > +       switch (mode) {
>> > +       case PHY_MODE_RGMII:
>> > +               return "RGMII";
>> > +       case PHY_MODE_TBI:
>> > +               return "TBI";
>> > +       case PHY_MODE_GMII:
>> > +               return "GMII";
>> > +       case PHY_MODE_MII:
>> > +               return "MII";
>> > +       case PHY_MODE_RTBI:
>> > +               return "RTBI";
>> > +       default:
>> > +               BUG();
>> > +       }
>>
>> Any reasons why you are duplicating what is available in
>> drivers/of/of_net.c ::of_get_phy_mode()?
>
> Unless I'm missing something of_get_phy_mode() is going the other way.
> rgmii_mode_name() is converting PHY_MODE_* into a human-readable string. I
> couldn't find any obvious kernel method to do this but maybe I missed it?

Right, rgmii_mode_name() just has informative purposes and should be
removed, I would suggest using standard device tree bindings property
(phy-mode) anyway such that you could use of_get_phy_mode() and use
phy_interface_t types.
-- 
Florian
