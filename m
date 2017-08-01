From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v2 net-next 1/3] net: dsa: lan9303: Refactor
 lan9303_xxx_packet_processing()
Date: Tue, 1 Aug 2017 15:50:14 +0200
Message-ID: <faf9e431-c5e4-7fcc-0341-6fc46e3561fb@egil-hjelmeland.no>
References: <20170801111439.1143-1-privat@egil-hjelmeland.no>
 <20170801111439.1143-2-privat@egil-hjelmeland.no>
 <20170801133934.GB23157@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801133934.GB23157@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01. aug. 2017 15:39, Andrew Lunn wrote:
>> @@ -704,7 +710,7 @@ static void lan9303_get_ethtool_stats(struct dsa_switch *ds, int port,
>>   	unsigned int u, poff;
>>   	int ret;
>>   
>> -	poff = port * 0x400;
>> +	poff = LAN9303_SWITCH_PORT_REG(port, 0);
>>   
>>   	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
>>   		ret = lan9303_read_switch_reg(chip,
> 
> So the actual code is:
> 
> 	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
>         		ret = lan9303_read_switch_reg(chip,
> 			      		      lan9303_mib[u].offset + poff,
> 					      &reg);
> 
> Could this be written as
> 
> 	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
> 		ret = lan9303_read_switch_port(chip, port, lan9303_mib[u].offset, &reg);
> 
> It is then clear you are reading the statistics from a port register.
> 
>     Andrew
> 

Yes it can. Since it is (insignificantly) less efficient, I
chose not to touch it. But I can do it if you like.

Egil
