From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: bcm_sf2: add VLAN support
Date: Thu, 09 Jun 2016 22:13:24 -0700 (PDT)
Message-ID: <20160609.221324.1107821306644656550.davem@davemloft.net>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbcFJFN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 01:13:26 -0400
In-Reply-To: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  9 Jun 2016 17:42:04 -0700

> This is long overdue, finally add support for VLANs in the Broadcom Starfigther
> 2 switch driver.
> 
> There are a few things that make us differ from e.g; mv88e6xxx.c:
> 
> - we keep a software cache of which VLANs are enabled and which are not to
>   dramatically speed up the VLAN dump operation, we do not have any HW operation
>   which would only return the list of valid VLAN entries, they would have to be
>   all queried one by one, with 4K vlans, this takes a while
> 
> - the default behavior is equivalent to setting VLAN filtering to 1, still working
>   on implementing a proper port_vlan_filtering callback, but I figured the most
>   conservative behavior is probably okay anyway
> 
> - without enabling VLANs, the default behavior is to receive any 802.1q frames
>   (per the DSA documentation), however, once we start enabling VLAN support, if
>   an interface leaves the bridge, we still want it to receive all 802.1q frames
>   so we utiliez the "Join all VLAN" feature of the switch to perform that

Series applied, thanks Florian.

I wonder how many other switch chip drivers could benefit from the
VLAN sw caching thing.
