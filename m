From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: Porting ethernet over spi driver
Date: Tue, 22 Apr 2014 12:02:36 +0200
Message-ID: <53563E3C.3030108@i2se.com>
References: <5350ED9E.6080103@lategoodbye.de> <1398133328.3624.186.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stefan Wahren <info@lategoodbye.de>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:62426 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbaDVKCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 06:02:39 -0400
In-Reply-To: <1398133328.3624.186.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.04.2014 04:22, schrieb Ben Hutchings:
> On Fri, 2014-04-18 at 11:17 +0200, Stefan Wahren wrote:
>> Hi,
>>
>> i'm trying to port a ethernet over spi driver to current mainline, which 
>> originally based on kernel 2.6.
>>
>> Now i'm searching for some guidelines, checklists, common pitfalls or 
>> just hints about that.
>>
>> Is there something about that, which is up to date?
> I don't think there is.
>
>> Is there a list or something of legacy function, which shouldn't be used 
>> anymore?
> No but the compiler should tell you about functions that were removed!
>
>> Are there any new must have features?
> You don't say which 2.6.y version you started with, but API changes I
> can think of that come up when backporting are:

Sorry for being so imprecise, it is 2.6.35.

> - 2.6.24: NAPI now involves a napi_struct rather than fields in
> net_device
> - 2.6.29: net device operation pointers moved into struct net_device_ops
> - 2.6.29: GRO added (can be useful if you have RX checksum offload)
> - 2.6.36: ndo_get_stats64 added as alternative to ndo_get_stats
> - 2.6.37: vlan_hwaccel_* functions removed; the driver must attach the
> tag and call the regular receive function
> - 2.6.39: ethtool feature setting replaced by net device operations
> ndo_fix_features & ndo_set_features
> - 3.2: ndo_set_multicast_list and ndo_set_rx_mode operations merged
> - 3.10: VLAN functions and feature flags changed to allow for both
> 802.1q and 802.1ad tags

Thank you for this list.

> Most of the interesting new features are related to multiqueue and
> protocol offloads that I wouldn't expect to exist in an SPI-attached
> Ethernet controller.  

You are right.

Btw, is simple power management (suspend, resume) a must-have feature?

BR Stefan Wahren
