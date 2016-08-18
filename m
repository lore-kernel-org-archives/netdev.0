From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Thu, 18 Aug 2016 12:28:07 +0300
Message-ID: <CAKdSkDW5Q6cK+1XGsA5SGMkdMOMLm1uy-HaMLoB+-K4CLchhww@mail.gmail.com>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
 <20295.1467215964@famine> <CAKdSkDXprDpOUbKqw7+sqAj8LZ2tGC17YONmX0D1oLLUnCvRYw@mail.gmail.com>
 <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com>
 <29688.1467753616@famine> <CAKdSkDUkW5DaM_nDkyMNAhWC_MAXK2pXzt-T9opQKDm0xdhibQ@mail.gmail.com>
 <21892.1467942487@famine> <CAKdSkDUvv1YNp5hmposci87_yZqkanS3zswL4txOCzA+CJFgSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34415 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbcHRJ2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 05:28:10 -0400
Received: by mail-lf0-f47.google.com with SMTP id l89so7909758lfi.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 02:28:09 -0700 (PDT)
In-Reply-To: <CAKdSkDUvv1YNp5hmposci87_yZqkanS3zswL4txOCzA+CJFgSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-08 15:22 GMT+03:00 Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>:
> 2016-07-08 4:48 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:

>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index edc70ffad660..2da5be91226e 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -1713,18 +1713,12 @@ static void ad_agg_selection_logic(struct aggregator *agg,
>>                 *update_slave_arr = true;
>>         }
>>
>> -       /* if the selected aggregator is of join individuals
>> -        * (partner_system is NULL), enable their ports
>> -        */
>>         active = __get_active_agg(origin);
>>
>>         if (active) {
>> -               if (!__agg_has_partner(active)) {
>> -                       for (port = active->lag_ports; port;
>> -                            port = port->next_port_in_aggregator) {
>> -                               __enable_port(port);
>> -                       }
>> -               }
>> +               for (port = active->lag_ports; port;
>> +                    port = port->next_port_in_aggregator)
>> +                       __enable_port(port);
>>         }
>>
>>         rcu_read_unlock();
>>
>>
>>         Rather than adding a new loop as your original patch did, this
>> one repurposes the existing loop for individual links and does the
>> enable for all cases.
>>
>>         I think this may still need a check for the port state in there,
>> as ports in the aggregator may be link up but still not suitable for
>> TX/RX if the LACP negotiation doesn't put the port into COLL_DIST state.
>>
>>         Enabling a port that is already enabled is harmless, and if the
>> port is link down, the enable will do nothing, so I think this should
>> resolve things.
>
> I can test any patches with additional checks, but this change seems
> to fix it for us.

Do you think something else is needed is addition to this? This has
been working on my servers now for some time without problems. I
tested this also against mainline 4.8-rc1 that needed it for bonding
to work properly with the previous test case.

Veli-Matti
