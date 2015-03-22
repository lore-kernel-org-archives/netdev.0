From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Sun, 22 Mar 2015 13:45:49 -0700
Message-ID: <550F29FD.7050509@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net> <1426952815-4642-9-git-send-email-linux@roeck-us.net> <20150322200600.GD15025@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150322200600.GD15025@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2015 01:06 PM, Andrew Lunn wrote:
> Hi Guenter
>
>> +static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
>> +{
>> +	int ret;
>> +
>> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
>> +	if (ret < 0)
>> +		return ret;
>
> Please could you check this. I think register 0x01 here is wrong. I
> think you want 0x0b, the ATU Operations register?
>
The ATU operation is initiated below (and does write to register 0x0b).
Register 0x01 is FID[11..0] for ATU, which is what we want to write here.

Guenter

> Thanks
> 	Andrew
>
>> +
>> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0b, cmd);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	return _mv88e6xxx_atu_wait(ds);
>> +}
>> +
>
