From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/5] net: dsa: split dsa_port's netdev member
Date: Thu, 12 Oct 2017 19:21:54 -0400
Message-ID: <87r2u86jfx.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com> <20171012225156.20758-6-vivien.didelot@savoirfairelinux.com> <5b637ea3-6c4b-1d93-ed43-09038af473f9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5b637ea3-6c4b-1d93-ed43-09038af473f9@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 10/12/2017 03:51 PM, Vivien Didelot wrote:
>> The dsa_port structure has a "netdev" member, which can be used for
>> either the master device, or the slave device, depending on its type.
>> 
>> It is true that today, CPU port are not exposed to userspace, thus the
>> port's netdev member can be used to point to its master interface.
>> 
>> But it is still slightly confusing, so split it into more explicit
>> "master" and "slave" members.
>
> I do see some value in doing that, although I also see value in having
> structure members be named after what they are, rather than their use
> (oh well, it's all debatable anyway), see below for a suggestion on how
> to reconcile the two:
>
>>  struct dsa_port {
>> +	/* Master device, physically connected if this is a CPU port */
>> +	struct net_device *master;
>> +
>> +	/* Slave device, if this port is exposed to userspace */
>> +	struct net_device *slave;
>> +
>
> How about using:
>
> 	union {
> 		struct net_device *master;
> 		struct net_device *slave;
> 	} netdev;
>
> Such that this serves both purposes of clearly communicating what the
> structure member is, and it can be either one of the two, but not both
> at the same time?

I love that! It makes clear that master is not available for a non-CPU
port. Using this union is correct for the moment because DSA and CPU
ports don't have a slave device attached to them. If this becomes true
one day (unlikely), we'll remove the union.


Thanks,

        Vivien
