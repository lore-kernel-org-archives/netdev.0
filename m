From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Mon, 15 May 2017 14:20:53 -0700
Message-ID: <480588af-0cb3-b14c-8443-7df36de0cb94@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40A632C2@CHN-SV-EXMX02.mchp-main.com>
 <20170513131341.GC14058@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40A654D1@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        davem@davemloft.net, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34000 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdEOVU7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 17:20:59 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so31792835wmf.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 14:20:59 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A654D1@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2017 02:01 PM, Woojung.Huh@microchip.com wrote:
>>> +static const struct ksz_chip_data ksz_switch_chips[] = {
>>> +	{
>>> +		.chip_id = 0x00947700,
>>> +		.dev_name = "KSZ9477",
>>> +		.num_vlans = 4096,
>>> +		.num_alus = 4096,
>>> +		.num_statics = 16,
>>> +		.enabled_ports = 0x1F,	/* port0-4 */
>>> +		.cpu_port = 5,		/* port5 (RGMII) */
>>> +		.port_cnt = 7,
>>> +		.phy_port_cnt = 5,
>>> +	},
>>> +};
>>
>> Hi Woojung
>>
>> Do we need cpu_port in this table? Can any port be used as a CPU port?
>> From the code in ksz_config_cpu_port() it seems like it can.
>>
>> And do we need enabled_ports? This seems to suggest only ports 0-4 can
>> be user ports?
>>
> Andrew,
> 
> Intention of cpu_port is for default cpu_port when devicetree doesn't have it.
> However, it won't get back to dst, so it won't be needed.
> Will remove it.
> 
> Enabled_ports was to configure physically connected ports. (For instance, 7 ports switch but board only uses 4 ports.)
> This code path is not working as expected. Will update at next version of patch.

FWIW, the b53 driver has a similar set of constructs (which is probably
where you got this from), and this needs fixing too. cpu_port is a good
indication of which ports can support tags, whereas enabled_ports is
completely redundant with ds->enabled_port_mask.

Once net-next opens again, the plan is to stop using these private
constructs and switch to using what DSA provides.

BTW, there are only a few things that make sense to be represented as a
true number, most attributes of a switch (port number, locations etc.)
are truly bitmasks.
-- 
Florian
