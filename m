From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v3 net-next v3 13/14] net: dsa: mv88e6xxx: add addressing mode to info
Date: Sat, 18 Jun 2016 17:18:24 -0400
Message-ID: <8737oa42n3.fsf@ketchup.mtl.sfl>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com> <20160618000736.5598-14-vivien.didelot@savoirfairelinux.com> <20160618203639.GH7172@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160618203639.GH7172@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +struct mv88e6xxx_smi_ops {
>> +	int (*read)(struct mii_bus *bus, int sw_addr,
>> +		    int addr, int reg, u16 *val);
>> +	int (*write)(struct mii_bus *bus, int sw_addr,
>> +		     int addr, int reg, u16 val);
>> +};
>
> Hi Vivien
>
> I still think this API should be based on ps.
>
> With the way you have restructured probe, this now also works, there
> is no longer a read without PS in order to get the device ID.
>
> Also, think about the case of reading/writing registers via Ethernet
> frames. Such functions would need ps, bus and sw_addr is not useful.

Yes, I do RMU in mind, that was one motivation behind isolating
SMI-specific pieces of code.

I considered mv88e6xxx_smi_ops private to the SMI (MDIO) access, needing
an additional abstraction for regs access operations.

But I can indeed rename mv88e6xxx_smi_ops to mv88e6xxx_ops and make them
use a ps before one day, implementing an optional ps->rmu_ops.

Thanks,

        Vivien
