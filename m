From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: add MDB support
Date: Wed, 31 Aug 2016 20:33:54 +0300
Message-ID: <74ccc395-74ca-26a9-fa3b-02880c4fdc27@cogentembedded.com>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
 <20160829203246.18811-4-vivien.didelot@savoirfairelinux.com>
 <20160831135719.GC15078@lunn.ch> <874m618095.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:36706 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161173AbcHaRd7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:33:59 -0400
Received: by mail-lf0-f42.google.com with SMTP id g62so42224115lfe.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 10:33:59 -0700 (PDT)
In-Reply-To: <874m618095.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/31/2016 05:46 PM, Vivien Didelot wrote:

>>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
>>> index 93abfff..812cb47 100644
>>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>>> @@ -2240,6 +2240,15 @@ static int mv88e6xxx_port_db_dump_one(struct mv88e6xxx_chip *chip,
>>>  				fdb->ndm_state = NUD_NOARP;
>>>  			else
>>>  				fdb->ndm_state = NUD_REACHABLE;
>>> +		} else {
>>
>> Rather than else, i think it would be safer to do
>>
>> 		if (obj->id == SWITCHDEV_OBJ_ID_PORT_MDB) {
>>> +			struct switchdev_obj_port_mdb *mdb;
>>> +
>>> +			if (!is_multicast_ether_addr(addr.mac))
>>> +				continue;
>>> +
>>> +			mdb = SWITCHDEV_OBJ_PORT_MDB(obj);
>>> +			mdb->vid = vid;
>>> +			ether_addr_copy(mdb->addr, addr.mac);
>>>  		}
>>
>> It should not happen, but the day it does, we get very confused...
>
> Do you mean the something like this?
>
>     if (obj->id == SWITCHDEV_OBJ_ID_PORT_FDB) {
>         ...
>     } else if (obj->id == SWITCHDEV_OBJ_ID_PORT_MDB) {
>         ...
>     } else {
>         return -EOPNOTSUPP;
>     }
>
> I'm OK with that if you think it is better.

    Just code it as a *switch*, please. :-)

[...]

MBR, Sergei
