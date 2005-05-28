From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH] r8169: support restricting speed+duplex in autonegotiation
Date: Sat, 28 May 2005 14:28:25 +0100
Message-ID: <429871F9.6040305@phekda.gotadsl.co.uk>
References: <4297A0F7.5070209@phekda.gotadsl.co.uk> <4297B479.1080404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Linux netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4297B479.1080404@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Ben Greear wrote:
> Richard Dawe wrote:
> 
>> Hello.
>>
>> Attached is a patch for drivers/net/r8169.c against Linux 2.6.11 that 
>> allows adjustment of the speed and duplex advertised via 
>> autonegotiation. Example usage:
>>
>>   ethtool -s eth0 autoneg on speed 10 duplex half
[snip]
>> r8169: Allow adjustment of speed and duplex advertised via 
>> autonegotiation
>>
>> Signed-off-by: Richard Dawe <rich@phekda.gotadsl.co.uk>
>>
>>
>> ------------------------------------------------------------------------
>>
>> --- r8169.c.orig    2005-05-27 21:12:21.000000000 +0100
>> +++ r8169.c    2005-05-27 22:14:59.000000000 +0100
[snip]
>> @@ -579,6 +583,23 @@ static void rtl8169_link_option(int idx,
>>      *autoneg = p->autoneg;
>>      *speed = p->speed;
>>      *duplex = p->duplex;
>> +
>> +    if (p->media == _10_Half)
>> +        *advertising = ADVERTISED_10baseT_Half;
>> +    if (p->media == _10_Full)
>> +        *advertising = ADVERTISED_10baseT_Full;
>> +    if (p->media == _100_Half)
>> +        *advertising = ADVERTISED_100baseT_Half;
>> +    if (p->media == _100_Full)
>> +        *advertising = ADVERTISED_100baseT_Full;
>> +    if (p->media == _1000_Full)
>> +        *advertising = ADVERTISED_1000baseT_Full;
>> +    if (p->media == 0xff)
>> +        *advertising = ADVERTISED_10baseT_Half |
>> +                   ADVERTISED_10baseT_Full |
>> +                   ADVERTISED_100baseT_Half |
>> +                   ADVERTISED_100baseT_Full |
>> +                   ADVERTISED_1000baseT_Full;
>>  }
> 
> 
> So, is there no way to advert just 100Mbps-half and -full ?
> 
> Seems like you should be able to set each flag by itself and
> create a bit-mask of the particular flags that you want...

This particular code is to support the "media" option for the r8169 
module. The "media" option is marked as deprecated in favour of ethtool.

It looks like you could control what is advertised by using the ethool 
ioctls, since you can pass a bitmask to that. I can't see a way to do 
that with the ethtool command, since you can only specify one pair of 
"speed" and "duplex" arguments.

One thing I forgot to mention in my mail is that there is no way of 
disabling autonegotiation with the r8169 driver. I started working on 
this, but I don't know how to force the PHY to a particular speed+duplex 
combination with autonegotation switched off. I'm guessing that 
autonegotiation enabled with one advertised speed+duplex != fixed 
speed+duplex.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
