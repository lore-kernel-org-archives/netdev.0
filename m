From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH v3 4/5] ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration
Date: Tue, 21 Feb 2017 10:49:05 +0200
Message-ID: <CABBYNZK7TCMRVcVHWvDcsn3waDX-aks76gqemvv9EmmAdHjvOA@mail.gmail.com>
References: <20170217155003.4594-1-luiz.dentz@gmail.com> <20170217155003.4594-5-luiz.dentz@gmail.com>
 <2ea89126-3c3b-5754-7bfc-7e8dc0f356d9@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
        Patrik Flykt <patrik.flykt@linux.intel.com>,
        Alexander Aring <aar@pengutronix.de>,
        linux-wpan@vger.kernel.org,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34634 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbdBUItG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 03:49:06 -0500
In-Reply-To: <2ea89126-3c3b-5754-7bfc-7e8dc0f356d9@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan,

On Tue, Feb 21, 2017 at 12:10 AM, Stefan Schmidt <stefan@osg.samsung.com> wrote:
> Hello.
>
> [Added netdev in cc as it touches ipv6/addrconf]
>
> 6LoWPAN handling changes only so an ACK should be ok and we could carry it
> through the bluetooth tree after the respin (see below).
>
> David, is that ok with you?
>
>
> On 02/17/2017 04:50 PM, Luiz Augusto von Dentz wrote:
>>
>> From: Alexander Aring <aar@pengutronix.de>
>>
>> This patch adds support for 48 bit 6LoWPAN address length
>> autoconfiguration which is the case for BTLE 6LoWPAN.
>>
>> Signed-off-by: Alexander Aring <aar@pengutronix.de>
>> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
>> ---
>>  net/ipv6/addrconf.c | 17 ++++++++++++-----
>>  1 file changed, 12 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index ac9bd56..dede33f 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -2050,12 +2050,19 @@ static void addrconf_leave_anycast(struct
>> inet6_ifaddr *ifp)
>>         __ipv6_dev_ac_dec(ifp->idev, &addr);
>>  }
>>
>> -static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
>> +static int addrconf_ifid_6lowpan(u8 *eui, struct net_device *dev)
>>  {
>> -       if (dev->addr_len != EUI64_ADDR_LEN)
>> +       switch (dev->addr_len) {
>> +       case ETH_ALEN:
>> +               return addrconf_ifid_eui48(eui, dev);
>> +       case EUI64_ADDR_LEN:
>> +               memcpy(eui, dev->dev_addr, EUI64_ADDR_LEN);
>> +               eui[0] ^= 2;
>> +               break;
>> +       default:
>>                 return -1;
>> -       memcpy(eui, dev->dev_addr, EUI64_ADDR_LEN);
>> -       eui[0] ^= 2;
>> +       }
>> +
>>         return 0;
>>  }
>>
>> @@ -2146,7 +2153,7 @@ static int ipv6_generate_eui64(u8 *eui, struct
>> net_device *dev)
>>         case ARPHRD_IPGRE:
>>                 return addrconf_ifid_gre(eui, dev);
>>         case ARPHRD_6LOWPAN:
>> -               return addrconf_ifid_eui64(eui, dev);
>> +               return addrconf_ifid_6lowpan(eui, dev);
>>         case ARPHRD_IEEE1394:
>>                 return addrconf_ifid_ieee1394(eui, dev);
>>         case ARPHRD_TUNNEL6:
>>
>
> Against which tree did you make this patch? Seems it needs a rebase.
>
> Applying it against bluetooth-next master branch:
>
> Applying: ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration
> error: patch failed: net/ipv6/addrconf.c:2146
> error: net/ipv6/addrconf.c: patch does not apply
> Patch failed at 0001 ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration

It should be fine in v4:

Applying: ipv6: addrconf: fix 48 bit 6lowpan autoconfiguration
Using index info to reconstruct a base tree...
M net/ipv6/addrconf.c
Falling back to patching base and 3-way merge...
Auto-merging net/ipv6/addrconf.c

-- 
Luiz Augusto von Dentz
