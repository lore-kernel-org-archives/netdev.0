From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: [PATCH] net: sky2: allow mac to come from dt
Date: Wed, 5 Mar 2014 07:38:01 -0800
Message-ID: <CAJ+vNU1-LFxC+fNiwO+Jiyzp0PZMM7h4xA2wYCrgasY9vXg5aA@mail.gmail.com>
References: <1394000535-25559-1-git-send-email-tharvey@gateworks.com>
	<CAL_JsqLUOzGW7u2FqUKQQ8gu2m8ksBR48oHkfLZmbkUNtzxpSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:44234 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbaCEPiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 10:38:03 -0500
Received: by mail-we0-f181.google.com with SMTP id q58so1412398wes.40
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 07:38:01 -0800 (PST)
In-Reply-To: <CAL_JsqLUOzGW7u2FqUKQQ8gu2m8ksBR48oHkfLZmbkUNtzxpSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 4, 2014 at 10:32 PM, Rob Herring <robherring2@gmail.com> wrote:
<snip>
>> @@ -4805,8 +4808,27 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
>>
>>         dev->features |= dev->hw_features;
>>
>> +       /* try to get mac address in the following order:
>> +        * 1) from device tree data
>> +        * 2) from internal registers set by bootloader
>> +        */
>> +       iap = NULL;
>> +       if (IS_ENABLED(CONFIG_OF)) {
>
> This shouldn't be needed.
>
>> +               struct device_node *np = hw->pdev->dev.of_node;
>> +               if (np)
>> +                       iap = (unsigned char *) of_get_mac_address(np);
>> +       }
>
> This should all just be 1 line. of_get_mac_address should just return
> NULL if !CONFIG_OF or np == NULL.

agreed - I verified this is true

>
>> +
>> +       /* 2) mac registers set by bootloader
>> +        */
>> +       if (!iap || !is_valid_ether_addr(iap)) {
>
> Perhaps is_valid_ether_addr check should also be moved into of_get_mac_address.
>

looks like it already does that - I'll simplify the above

> Rob

Thanks for the review!

Tim
