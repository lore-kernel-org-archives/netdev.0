From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC] b44: use phylib
Date: Wed, 18 Sep 2013 16:29:01 +0100
Message-ID: <CAGVrzca_jpNKohDuz5fTvXdCsyV7F7c5TbrQwb-suEqiKZkT5g@mail.gmail.com>
References: <1377298608-18016-1-git-send-email-hauke@hauke-m.de> <1379517545.1787.20.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hauke Mehrtens <hauke@hauke-m.de>, zambrano@broadcom.com,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:38722 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab3IRP3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 11:29:42 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so7149329pbc.31
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 08:29:41 -0700 (PDT)
In-Reply-To: <1379517545.1787.20.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/9/18 Joe Perches <joe@perches.com>:
> On Sat, 2013-08-24 at 00:56 +0200, Hauke Mehrtens wrote:
>> This splits the driver into the mac and a phy driver. On routers where
>> this driver is used we have a switch which implements a phy and can be
>> controlled by a phy driver.
>
> One more trivial note:
>
>> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
> []
>> +static void b44_adjust_link(struct net_device *dev)
>> +{
> []
>> +     if (status_changed) {
>> +             pr_info("%s: link %s", dev->name, phydev->link ?
>> +                     "UP" : "DOWN");
>> +             if (phydev->link)
>> +                     pr_cont(" - %d/%s", phydev->speed,
>> +                     phydev->duplex == DUPLEX_FULL ? "full" : "half");
>> +             pr_cont("\n");
>> +     }
>
> This bit would be better as:
>
>         if (status_change) {
>                 if (phydev->link)
>                         netdev_info(dev, "link UP - %d/%s\n",
>                                     phydev->speed,
>                                     phydev->duplex == DUPLEX_FULL
>                                     ? "full" : "half");
>                 else
>                         netdev_info(dev, "link DOWN\n");
>         }

There is a helper function provided by phylib for this: phy_print_status().
-- 
Florian
