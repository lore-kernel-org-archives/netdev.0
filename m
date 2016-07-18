From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 03/12] net: dsa: mv88e6xxx: extract device mapping
Date: Mon, 18 Jul 2016 15:42:28 -0400
Message-ID: <87h9bm3f8b.fsf@ketchup.mtl.sfl>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com> <20160718184628.13103-4-vivien.didelot@savoirfairelinux.com> <20160718193558.GK31103@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160718193558.GK31103@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +/* Indirect write to single pointer-data register with an Update bit */
>> +static int mv88e6xxx_update_write(struct mv88e6xxx_chip *chip,
>> +				  int addr, int reg, u16 update)
>
> Hi Vivien
>
> I don't think mv88e6xxx_update_read() makes any sense? Can we just
> infer write? Call it mv88e6xxx_update().

Yes it does, a read operation in such register consists of write+read
(first write the pointer to read, then read the actual value.)

>> +static int mv88e6xxx_g2_device_mapping_write(struct mv88e6xxx_chip *chip,
>> +					     int target, int port)
>> +{
>> +	u16 val = (target << 8) | (port & 0xf);
>> +
>> +	return mv88e6xxx_update_write(chip, REG_GLOBAL2, GLOBAL2_DEVICE_MAPPING,
>> +				      val);
>
> This would then all be on one line and look a better.

I plan to add more cleanup for register description later, such as
s/REG_GLOBAL2/ADDR_G2/ and s/GLOBAL2_/G2/. But that'll be a future patch.

Thanks,

        Vivien
