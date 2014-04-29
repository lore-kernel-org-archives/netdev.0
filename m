From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 08:57:20 -0500
Message-ID: <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
	<1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:60820 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbaD2N5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 09:57:22 -0400
Received: by mail-wi0-f170.google.com with SMTP id bs8so7058359wib.3
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 06:57:21 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 8:38 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Of Frank Li
> ...
>> When we timeout on transmit, it would be useful to dump the transmit
>> ring, so we can see the ring state.  This can be helpful to diagnose
>> the cause of transmit timeouts.
> ...
>> +static void fec_dump(struct net_device *ndev)
>> +{
>> +     struct fec_enet_private *fep = netdev_priv(ndev);
>> +     struct bufdesc *bdp = fep->tx_bd_base;
>> +     unsigned index = 0;
>> +
>> +     netdev_info(ndev, "TX ring dump\n");
>> +     pr_info("Nr     SC     addr       len  SKB\n");
>> +
>> +     do {
>> +             pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
>> +                     index,
>> +                     bdp == fep->cur_tx ? 'S' : ' ',
>> +                     bdp == fep->dirty_tx ? 'H' : ' ',
>> +                     bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
>> +                     fep->tx_skbuff[index]);
>> +             bdp = fec_enet_get_nextdesc(bdp, fep);
>> +             index++;
>> +     } while (bdp != fep->tx_bd_base);
>> +}
>> +
>
> You probably want the read and write indexes as well.

                     bdp == fep->cur_tx ? 'S' : ' ',
                     bdp == fep->dirty_tx ? 'H' : ' ',

Above code already print read and write index. 'S', 'H'

Frank Li

>
>         David
>
>
>
