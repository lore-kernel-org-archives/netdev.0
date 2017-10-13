From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: RE: [PATCH net-next v2 2/4] net: dsa: mv88e6060: setup random mac address
Date: Fri, 13 Oct 2017 12:44:44 -0400
Message-ID: <871sm7j8ub.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171013014113.29561-1-vivien.didelot@savoirfairelinux.com> <20171013014113.29561-3-vivien.didelot@savoirfairelinux.com> <063D6719AE5E284EB5DD2968C1650D6DD0094F25@AcuExch.aculab.com> <9235D6609DB808459E95D78E17F2E43D40B512EB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        davem@davemloft.net, f.fainelli@gmail.com, andrew@lunn.ch
To: Woojung.Huh@microchip.com, David.Laight@ACULAB.COM,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39590 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdJMQoq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 12:44:46 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B512EB@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Woojung,

Woojung.Huh@microchip.com writes:

>> From: Vivien Didelot
>> > Sent: 13 October 2017 02:41
>> > As for mv88e6xxx, setup the switch from within the mv88e6060 driver with
>> > a random MAC address, and remove the .set_addr implementation.
>> >
>> > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> > ---
>> >  drivers/net/dsa/mv88e6060.c | 30 +++++++++++++++++++-----------
>> >  1 file changed, 19 insertions(+), 11 deletions(-)
>> >
>> > diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
>> > index 621cdc46ad81..2f9d5e6a0f97 100644
>> > --- a/drivers/net/dsa/mv88e6060.c
>> > +++ b/drivers/net/dsa/mv88e6060.c
>> ...
>> > +	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, (addr[0] << 9) |
>> addr[1]);
>> 
>> Is that supposed to be 9 ?
>
> Looks like it.
> Check http://www.marvell.com/switching/assets/marvell_linkstreet_88E6060_datasheet.pdf

Hum, David is correct, there is a bug in the driver which needs to be
addressed first. MAC address bit 40 is addr[0] & 0x1, thus we must
shift byte 0 by 8 and mask it against 0xfe.

I'll respin this serie including a fix for both net and net-next.


Thanks,

        Vivien
