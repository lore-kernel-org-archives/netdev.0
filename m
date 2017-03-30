From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/9] net: dsa: mv88e6xxx: program the PVT with all ones
Date: Thu, 30 Mar 2017 10:16:08 -0400
Message-ID: <8760iq3l5j.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com> <20170329203020.27042-4-vivien.didelot@savoirfairelinux.com> <20170330134521.GC17879@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330134521.GC17879@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +	for (dev = 0; dev < 32; ++dev) {
>> +		for (port = 0; port < 16; ++port) {
>> +			err = mv88e6xxx_pvt_map(chip, dev, port);
>> +			if (err)
>> +				return err;
>> +		}
>> +	}
>> +
>> +	return 0;
>
> Hi Vivien
>
> How about adding MV88E6XXX_MAX_PVT_SWITCHES and MV88E6XXX_MAX_PVT_PORTS?

Sure.

>> +static int mv88e6xxx_g2_pvt_op(struct mv88e6xxx_chip *chip, int src_dev,
>> +			       int src_port, u16 op)
>> +{
>> +	int err;
>> +
>> +	/* 9-bit Cross-chip PVT pointer: with GLOBAL2_MISC_5_BIT_PORT cleared,
>> +	 * source device is 5-bit, source port is 4-bit.
>> +	 */
>> +	op |= (src_dev & 0x1f) << 4;
>> +	op |= (src_port & 0xf);
>
> So here, are you hard coding the knowledge that we passed false to
> mv88e6xxx_g2_misc_5_bit_port()?  It kind of defeats the point of
> having the parameter. Maybe simplify the code and remove the
> parameter?

I usually like to have generic library functions, but you are correct
here, it gets inconsistent in this specific case. Unless we add a
dynamic PVT state to the chip, which is totally overkill by now.

I'll add mv88e6xxx_g2_misc_4_bit_port(struct mv88e6xxx_chip *chip).

Thanks,

        Vivien
