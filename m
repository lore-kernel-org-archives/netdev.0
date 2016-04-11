From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: FWD: [PATCH v2] Marvell phy: add fiber status check for some
 components
Date: Mon, 11 Apr 2016 12:47:28 -0700
Message-ID: <570BFF50.6060909@gmail.com>
References: <20160404132552.GH21828@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	charles-antoine.couret@nexvision.fr
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35308 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcDKTtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 15:49:32 -0400
Received: by mail-pa0-f47.google.com with SMTP id td3so127354563pab.2
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 12:49:31 -0700 (PDT)
In-Reply-To: <20160404132552.GH21828@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/16 06:25, Andrew Lunn wrote:
>> >From 564b767163d19355a3b5efaad195e93796570c71 Mon Sep 17 00:00:00 2001
>> From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
>> Date: Fri, 1 Apr 2016 16:16:35 +0200
>> Subject: [PATCH] Marvell phy: add fiber status check for some components
>>
>> Marvell's phy could have two modes: fiber and copper. Currently, the driver
>> checks only the copper mode registers to get the status link which could be
>> wrong.
>>
>> This commit add a handler to check fiber then copper status link.
>> If the fiber link is activated, the driver would use this information.
>> Else, it would use the copper status.
> 
> Hi Florian
> 
> What do you think about this?
> 
> This works for basic status information. But what about other ethtool
> options? Setting the speed and duplex, turning pause on/off, etc.

Agreed, it seems like a PHY configured for fiber will need to provide
these informations differently, or does the standard BMSR register
provide accurate information already?

> 
> Do we actually need to stay on page 1 if fibre is in use? How do we
> initially change to page 1 when the fibre link is still down?

I also do not feel very comfortable with reading the fiber status first,
and then copper and then combine these two. At the very best, could we
do something like:

- identify if the PHY is configured for fiber in drv->probe or
drv->config_init, retain that information
- have two paths in drv->read_status which take care of reading one
status or the other?

Are there other side effects for other register accesses (say,
statistics, or auto-negotiation) that need to be fiber vs. copper aware?

> 
> Should we be using the old mechanism to swap between TP, BNC and AUI
> to swap between copper and fibre?

Did you mean using ethtool -s <iface> port fibre for instance?
-- 
Florian
