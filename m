From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add addressing mode to info
Date: Tue, 14 Jun 2016 17:52:52 -0400
Message-ID: <874m8vfnez.fsf@ketchup.mtl.sfl>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com> <20160614183153.32327-13-vivien.didelot@savoirfairelinux.com> <20160614213448.GF12832@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614213448.GF12832@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> @@ -3681,7 +3681,7 @@ mv88e6xxx_smi_detect(struct device *dev, struct mii_bus *bus, int sw_addr,
>>  	u16 id;
>>  
>>  	ops = &mv88e6xxx_smi_direct_ops;
>> -	if (sw_addr > 0)
>> +	if (sw_addr > 0 && info->flags & MV88E6XXX_FLAG_MULTI_CHIP)
>>  		ops = &mv88e6xxx_smi_indirect_ops;
>
> Is sw_addr is > 0 and MV88E6XXX_FLAG_MULTI_CHIP is not set, you should
> return -EINVAL. The device tree is invalid.

OK, I'll change this snippet for the following until we explicitly add
support for such device with non-zero address and direct SMI access:

    if (sw_addr == 0)
        ops = &mv88e6xxx_smi_direct_ops;
    else if (info->flags & MV88E6XXX_FLAG_MULTI_CHIP)
        ops = &mv88e6xxx_smi_indirect_ops;
    else
        return NULL;

Thanks,

        Vivien
