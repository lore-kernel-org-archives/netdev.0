From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] DSA refactoring: set 1
Date: Wed, 13 Apr 2016 12:22:51 -0700
Message-ID: <570E9C8B.2080100@gmail.com>
References: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33935 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbcDMTY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 15:24:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id d184so4880527pfc.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 12:24:56 -0700 (PDT)
In-Reply-To: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/16 17:40, Andrew Lunn wrote:
> There has been a long running effort to refractor DSA probing to make
> the switches true linux devices. Here are a small collection of
> patches moving in this direction. Most have been seen before.
> 
> We take a little step forward by passing the dsa device point to the
> driver, thus allowing it to perform resource allocations using the
> normal mechanisms. This device structure will later be replaced by the
> devices own device structure.
> 
> Future patches will add a true driver probe function, so we rename the
> current probe function, cleaning up the namespace.
> 
> phys_port_mask continually confuses me, thinking it is about PHYs. But
> it is actually about ports enabled to the outside world. So rename it to
> enabled_port_mask.
> 
> Lots more patches yet to follow, this is just doing some ground work.

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Andrew!

> 
> v2:
>   enabled_port_mask instread of user_port_masks
>   Added Tested-by's and Reviewed-by.
> 
> Andrew Lunn (7):
>   net: dsa: Pass the dsa device to the switch drivers
>   net: dsa: Have the switch driver allocate there own private memory
>   net: dsa: Remove allocation of driver private memory
>   net: dsa: Keep the mii bus and address in the private structure
>   net: dsa: Rename DSA probe function.
>   dsa: Rename phys_port_mask to user_port_mask
>   dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
> 
>  drivers/net/dsa/bcm_sf2.c   | 24 +++++++++++++-------
>  drivers/net/dsa/mv88e6060.c | 47 +++++++++++++++++++++++---------------
>  drivers/net/dsa/mv88e6060.h | 11 +++++++++
>  drivers/net/dsa/mv88e6123.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6131.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6171.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6352.c | 14 +++++++-----
>  drivers/net/dsa/mv88e6xxx.c | 55 +++++++++++++++++++++++++++++++--------------
>  drivers/net/dsa/mv88e6xxx.h | 17 +++++++++++---
>  include/net/dsa.h           | 16 ++++++++-----
>  net/dsa/dsa.c               | 19 +++++++++-------
>  11 files changed, 166 insertions(+), 79 deletions(-)
> 


-- 
Florian
