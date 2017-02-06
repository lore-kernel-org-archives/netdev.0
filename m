From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 3/4] net: phy: Allow pre-declaration of MDIO
 devices
Date: Mon, 6 Feb 2017 11:08:07 -0800
Message-ID: <b14f74a5-4282-4735-ab90-975e1a563d34@gmail.com>
References: <20170204210245.14812-1-f.fainelli@gmail.com>
 <20170204210245.14812-4-f.fainelli@gmail.com>
 <20170206134808.GG32506@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33437 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751372AbdBFTIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 14:08:10 -0500
In-Reply-To: <20170206134808.GG32506@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2017 05:48 AM, Andrew Lunn wrote:
>> diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
>> index 8a57f0b1242d..8850fcaf50db 100644
>> --- a/include/linux/mod_devicetable.h
>> +++ b/include/linux/mod_devicetable.h
>> @@ -501,6 +501,7 @@ struct platform_device_id {
>>  	kernel_ulong_t driver_data;
>>  };
>>  
>> +#define MDIO_NAME_SIZE		32
> 
> ...
> 
>> +struct mdio_board_info {
>> +	const char	*bus_id;
>> +	char		modalias[MDIO_NAME_SIZE];
>> +
> 
> I think it might be better to use MII_BUS_ID_SIZE. These are all
> related, so using one define should avoid surprise buffer overruns,
> truncation's.

I considered doing that, but left it that way because I valued the
"const" qualifier more than running out of buffer space. What I could do
though, is change the strcmp() in drivers/net/phy/mdio-boardinfo.c to be
bound by MII_BUS_ID_SIZE.
-- 
Florian
