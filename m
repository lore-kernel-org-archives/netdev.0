From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Sun, 22 Mar 2015 15:45:35 -0700
Message-ID: <550F460F.8060705@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>	<1426952815-4642-9-git-send-email-linux@roeck-us.net>	<20150322200600.GD15025@lunn.ch> <20150322.182407.1915654260904903040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150322.182407.1915654260904903040.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2015 03:24 PM, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Sun, 22 Mar 2015 21:06:00 +0100
>
>> Hi Guenter
>>
>>> +static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
>>> +{
>>> +	int ret;
>>> +
>>> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
>>> +	if (ret < 0)
>>> +		return ret;
>>
>> Please could you check this. I think register 0x01 here is wrong. I
>> think you want 0x0b, the ATU Operations register?
>
> Just want to mention that register mnenomics would have made this
> bug more obvious :-)
>

Andrew is working on introducing those definitions, which is how he
found the problem. It is not a bug per se, though, since the register
definition changed across chip generations. The code works fine for
the chips we tested it with (6171, 6172, and 6352).

Guenter
