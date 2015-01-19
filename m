From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 2/2] sh_eth: Fix ethtool operation crash when net
 device is down
Date: Mon, 19 Jan 2015 09:28:06 -0800
Message-ID: <54BD3EA6.9000900@gmail.com>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>	 <1421430685.1222.192.camel@xylophone.i.decadent.org.uk>	 <CAGVrzcbj2JANTECtxgDUrb7c_20nyoW4n5ARndHGKYuQu-0kQg@mail.gmail.com> <1421664085.1222.200.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@lists.codethink.co.uk>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:40987 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbASR2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 12:28:19 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so40046830pad.1
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 09:28:19 -0800 (PST)
In-Reply-To: <1421664085.1222.200.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/01/15 02:41, Ben Hutchings wrote:
> On Fri, 2015-01-16 at 10:45 -0800, Florian Fainelli wrote:
>> 2015-01-16 9:51 GMT-08:00 Ben Hutchings <ben.hutchings@codethink.co.uk>:
> [...]
>>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>>> @@ -1827,6 +1827,9 @@ static int sh_eth_get_settings(struct net_device *ndev,
>>>         unsigned long flags;
>>>         int ret;
>>>
>>> +       if (!mdp->phydev)
>>> +               return -ENODEV;
>>
>> Since the PHY is disconnected, would not checking for netif_running()
>> make sense here, unless there is a good reason to still allow
>> phy_ethtool_gset() to be called?
> [...]
> 
> I think those two conditions will be equivalent, won't they?

They are indeed.

>  Writing the condition like this will also work if the driver later supports
> PHY-less configurations.

You could also represent a PHY-less configuration by using the emulated
fixed-PHY, such that the driver is effectively "driving" a PHY device,
even though this is not a real one, up to you.
-- 
Florian
