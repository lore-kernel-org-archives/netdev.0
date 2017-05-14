From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Sun, 14 May 2017 12:13:37 +0300
Message-ID: <7f0c4c6a-a6fd-5c4f-9c40-f23f694cee6f@cogentembedded.com>
References: <9235D6609DB808459E95D78E17F2E43D40A632C2@CHN-SV-EXMX02.mchp-main.com>
 <20170513145609.GD14058@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Andrew Lunn <andrew@lunn.ch>, Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:34104 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750882AbdENJNj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 05:13:39 -0400
Received: by mail-wr0-f171.google.com with SMTP id l9so62779760wre.1
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 02:13:39 -0700 (PDT)
In-Reply-To: <20170513145609.GD14058@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 5/13/2017 5:56 PM, Andrew Lunn wrote:

[...]

>> +static int ksz_reset_switch(struct dsa_switch *ds)
>> +{
>> +	struct ksz_device *dev = ds->priv;
>> +	u8 data8;
>> +	u16 data16;
>> +	u32 data32;
>> +
>
> ...
>
>> +
>> +	memset(dev->vlan_cache, 0, sizeof(*dev->vlan_cache) * dev->num_vlans);
>> +
>> +	return 0;
>> +}
>
>> +static int ksz_setup(struct dsa_switch *ds)
>> +{
>> +	struct ksz_device *dev = ds->priv;
>> +	int ret = 0;
>> +
>> +	dev->vlan_cache = devm_kmalloc_array(dev->dev,
>> +					     sizeof(struct vlan_table),
>> +					     dev->num_vlans, GFP_KERNEL);
>
> You should check, but i think devm_kmalloc_array sets the allocated
> memory to 0.

    No. Else there would be no need for it, since kcalloc() is a function that 
allocates the arrays and zeroes them.

> So i don't think you need the memset. If it is needed, i
> would move it here, after the check the allocation is successful.

    If it could be done here, kcalloc() should be used.

[...]

MBR, Sergei
