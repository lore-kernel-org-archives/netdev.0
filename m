From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add addressing mode to info
Date: Tue, 14 Jun 2016 18:24:17 -0400
Message-ID: <871t3z1ka6.fsf@ketchup.mtl.sfl>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com> <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com> <20160614220941.GJ12832@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39302 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbcFNWYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 18:24:20 -0400
In-Reply-To: <20160614220941.GJ12832@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> -	ret = mdiobus_read_nested(bus, addr, reg);
>> +	ret = mdiobus_read_nested(bus, sw_addr + addr, reg);
>>  	if (ret < 0)
>>  		return ret;
>
> If we are doing direct access, doesn't it means sw_addr is 0?
>
> So isn't this pointless?

6060 has no indirect access and directly responds to 16 SMI addresses,
regardless its chip address which can be strapped to either 0 or 16.

If we want to add support for it in mv88e6xxx someday (which is likely),
the code is ready for that.

Question 1) given this, should I still consider your first comment on
this patch about the mv88e6xxx_smi_ops assignment?

Question 2) is MV88E6XXX_FLAG_MULTI_CHIP confusing? I took a short name
for style but maybe a longer MV88E6XXX_FLAG_MULTI_CHIP_ADDRESSING or
MV88E6XXX_FLAG_MULTI_CHIP_MODE would be clearer to make to distinction
between "Single-chip Addressing Mode" and "Multi-chip Addressing Mode".

Thanks,

        Vivien
