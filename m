From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/6] net: dsa: mv88e6xxx: add helper for switch ready
Date: Thu, 01 Dec 2016 15:31:09 -0500
Message-ID: <87y3zzgzn6.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com> <20161130225930.25510-6-vivien.didelot@savoirfairelinux.com> <20161130233810.GT21645@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130233810.GT21645@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> As we have seen in the past, this sort of loop is broken if we end up
> sleeping for a long time. Please take the opportunity to replace it
> with one of our _wait() helpers, e.g. mv88e6xxx_g1_wait()

That won't work. the _wait() helpers are made to wait on self-clear (SC)
bits, i.e. looping until they are cleared to zero.

Here we want the opposite.

I will keep this existing wait loop for the moment and work soon on a
new patchset to rework the wait routines. We need a generic access to
test a given value against a given mask and wrappers for busy bits, etc.

>> +int mv88e6xxx_g1_init_ready(struct mv88e6xxx_chip *chip, bool *ready)
>> +{
>> +	u16 val;
>> +	int err;
>> +
>> +	/* Check the value of the InitReady bit 11 */
>> +	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
>> +	if (err)
>> +		return err;
>> +
>> +	*ready = !!(val & GLOBAL_STATUS_INIT_READY);
>
> I would actually do the wait here.

That is better indeed.

Thanks,

        Vivien
