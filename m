From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: phy: Add Speed downshift set driver for Microsemi PHYs.
Date: Mon, 17 Oct 2016 05:38:46 -0700
Message-ID: <A80DFF63-2C6B-4113-AA7D-AEEC0150EAF2@gmail.com>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com> <1476445233-26524-2-git-send-email-Raju.Lakkaraju@microsemi.com> <20161014121232.GH5822@lunn.ch> <20161017073152.GA2365@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Allan.Nielsen@microsemi.com
To: Raju.Lakkaraju@microsemi.com, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:32838 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933548AbcJQMiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:38:55 -0400
In-Reply-To: <20161017073152.GA2365@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 17, 2016 12:31:54 AM PDT, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com> wrote:
>Hi Andrew,
>
>Thank you for code review and comments.
>
>On Fri, Oct 14, 2016 at 02:12:32PM +0200, Andrew Lunn wrote:
>> EXTERNAL EMAIL
>> 
>> 
>> On Fri, Oct 14, 2016 at 05:10:32PM +0530, Raju Lakkaraju wrote:
>> > From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
>> >
>> > For operation in cabling environments that are incompatible with
>> > 1000BAST-T, VSC8531 device provides an automatic link speed
>> > downshift operation. When enabled, the device automatically changes
>> > its 1000BAST-T auto-negotiation to the next slower speed after
>> > a configured number of failed attempts at 1000BAST-T.
>> > This feature is useful in setting up in networks using older cable
>> > installations that include only pairs A and B, and not pairs C and
>D.
>> 
>> Any reason not to just turn this on by default when auto-neg is
>> enabled?
>> 
>Downshift can enable by default when auto-neg enabled. This is good
>idea.
>But we would like to provide option to customer can choose whether this
>feature need to enable or disable and also configure failure attempts.
>
>Do you have any other suggestion how to configure failure attempts?

Is the speed downshift feature similar to what Intel and Broadcom refer to as wirespeed? I have seen cases with Broadcom PHYs where we had to turn such a feature on to allow auto-negotiation to complete with 4-wire cables, but this had the downside of impacting normal autoneg, so it is left disabled.

I would expect the number of customers using this feature to be fairly limited, so having a tunable to turn this downshift on/off may be acceptable. Ethtool supports a number of tunable parameters now (such as rx_copybreak), there may be room for using something similar for boolean flags like these.

-- 
Florian
