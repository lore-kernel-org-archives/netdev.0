From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: handle multiple ports in ATU
Date: Mon, 19 Sep 2016 20:29:40 -0400
Message-ID: <87oa3jo1l7.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com> <20160920001914.GB6323@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920001914.GB6323@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Hi Vivien
>
>> +	do {
>> +		err = _mv88e6xxx_atu_getnext(chip, fid, &next);
>> +		if (err)
>> +			return err;
>> +
>> +		if (next.state == GLOBAL_ATU_DATA_STATE_UNUSED)
>> +			break;
>> +
>> +		if (ether_addr_equal(next.mac, addr)) {
>> +			*entry = next;
>> +			return 0;
>> +		}
>> +	} while (!is_broadcast_ether_addr(next.mac));
>
> This is correct, but i wonder how well it scales? When we have a lot
> of entries in the ATU, this is going to take time. At some point in
> the future, we might want to keep a shadow copy of static entries of
> the ATU in RAM. We then don't need to search for them.

There won't be any issue about time here, because we are searching a
precise FID. What takes time is dumping the whole 4095 FIDs at once.

> But that is for later, once we have some complaints this is too slow.

Yes, there are severals things we can cache in this driver, but to be
honest I'd prefer not to cache anything for the moment, until the driver
is robust. Caching data must be the very last point IMO.

Thanks,

        Vivien
