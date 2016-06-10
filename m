From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/4] net: dsa: bcm_sf2: Add VLAN support
Date: Fri, 10 Jun 2016 11:47:48 -0700
Message-ID: <575B0B54.7030305@gmail.com>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
 <1465519328-14249-5-git-send-email-f.fainelli@gmail.com>
 <20160610120046.GB2338@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35986 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbcFJSrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 14:47:51 -0400
Received: by mail-pf0-f196.google.com with SMTP id 62so5563275pfd.3
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 11:47:51 -0700 (PDT)
In-Reply-To: <20160610120046.GB2338@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2016 05:00 AM, Andrew Lunn wrote:
>> @@ -148,6 +155,9 @@ struct bcm_sf2_priv {
>>  	struct device_node		*master_mii_dn;
>>  	struct mii_bus			*slave_mii_bus;
>>  	struct mii_bus			*master_mii_bus;
>> +
>> +	/* Cache of programmed VLANs */
>> +	struct bcm_sf2_vlan		vlans[VLAN_N_VID];
> 
> Hi Florian
> 
> This is a 16Kbyte array. So i assume the whole priv structure needs 5
> pages. Have you had any trouble allocating this much memory,
> particularly once it has been used for a while and fragmented?

Well, since this is using the old binding, we can't unload the driver,
it's built into the kernel, so initializes early enough we have got
plenty of memory.

> 
> I just wondered if it might be better to use vmalloc() for the
> vlans.

That's a very good point, I can't really see a drawback to doing this,
will submit a patch moving this to a dynamic allocation.

Another possible approach would have been to allocate the vlan structure
upong port_vlan_prepare() though that would typically result in more
fragmentation over time once se start using more VLANs.
-- 
Florian
