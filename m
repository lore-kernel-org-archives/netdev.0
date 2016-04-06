From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
Date: Wed, 6 Apr 2016 09:47:37 -0700
Message-ID: <57053DA9.2090404@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB1855C389F2265E30252D62B5FF9F0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
 <57053C94.2000009@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"gerg@uclinux.org" <gerg@uclinux.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"lznuaa@gmail.com" <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34663 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcDFQrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 12:47:40 -0400
Received: by mail-pf0-f178.google.com with SMTP id c20so37182243pfc.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 09:47:39 -0700 (PDT)
In-Reply-To: <57053C94.2000009@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/6/2016 9:43 AM, Troy Kisky wrote:
> On 4/6/2016 1:51 AM, Fugang Duan wrote:
>> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Wednesday, April 06, 2016 10:26 AM
>>> To: netdev@vger.kernel.org; davem@davemloft.net; Fugang Duan
>>> <fugang.duan@nxp.com>; lznuaa@gmail.com
>>> Cc: Fabio Estevam <fabio.estevam@nxp.com>; l.stach@pengutronix.de;
>>> andrew@lunn.ch; tremyfr@gmail.com; gerg@uclinux.org; linux-arm-
>>> kernel@lists.infradead.org; johannes@sipsolutions.net;
>>> stillcompiling@gmail.com; sergei.shtylyov@cogentembedded.com;
>>> arnd@arndb.de; Troy Kisky <troy.kisky@boundarydevices.com>
>>> Subject: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
>>>
>>> V3 has
>>>
>>> 1 dropped patch "net: fec: print more debug info in fec_timeout"
>>> 2 new patches
>>> 0002-net-fec-remove-unused-interrupt-FEC_ENET_TS_TIMER.patch
>>> 0003-net-fec-return-IRQ_HANDLED-if-fec_ptp_check_pps_even.patch
>>>
>>> 1 combined patch
>>> 0004-net-fec-pass-rxq-txq-to-fec_enet_rx-tx_queue-instead.patch
>>>
>>> The changes are noted on individual patches
>>>
>>> My measured performance of this series is
>>>
>>> before patch set
>>> 365 Mbits/sec Tx/407 RX
>>>
>>> after patch set
>>> 374 Tx/427 Rx
>>>
>>
>> I doubt the performance data,  I validate it on i.MX6q sabresd board on the latest commit(4da46cebbd3b) in net tree.
> 
> 
> 
> I was doing UDP tests, as outlined in my V2 cover letter. Also, my cpu is 1G. Is yours 1.2G?
> 
> 
> 
> 
>> root@imx6qdlsolo:~# uname -a
>> Linux imx6qdlsolo 4.6.0-rc1-00318-g4da46ce #180 SMP Wed Apr 6 16:24:09 CST 2016 armv7l GNU/Linux
> 
> 
> This is the V2 patch that I dropped.


Sorry, your right. It is the current head, without this series.


> 
> I will force update my local net-next_master branch, to make testing this series easier.
> Note that my local net-next_master branch has about 19 patches on top of this series.
> so,
> 
> tkisky@office-server2:~/linux-imx6$ git reset --hard HEAD~19
> HEAD is now at a125da7 net: fec: don't set cbd_bufaddr unless no mapping error
> 
> 
>>
>> TCP RX performance is 602Mbps, TX is only 325Mbps,   TX path has some performance issue in net tree.
>> I will dig out it.
>>
>>
> 
> 
> More testing is always better. Thanks
> 
> 
>>>
>>> Troy Kisky (16):
>>>   net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
>>>   net: fec: remove unused interrupt FEC_ENET_TS_TIMER
>>>   net: fec: return IRQ_HANDLED if fec_ptp_check_pps_event handled it
>>>   net: fec: pass rxq/txq to fec_enet_rx/tx_queue instead of queue_id
>>>   net: fec: reduce interrupts
>>>   net: fec: split off napi routine with 3 queues
>>>   net: fec: don't clear all rx queue bits when just one is being checked
>>>   net: fec: set cbd_sc without relying on previous value
>>>   net: fec: eliminate calls to fec_enet_get_prevdesc
>>>   net: fec: move restart test for efficiency
>>>   net: fec: clear cbd_sc after transmission to help with debugging
>>>   net: fec: dump all tx queues in fec_dump
>>>   net: fec: detect tx int lost
>>>   net: fec: create subroutine reset_tx_queue
>>>   net: fec: call dma_unmap_single on mapped tx buffers at restart
>>>   net: fec: don't set cbd_bufaddr unless no mapping error
>>>
>>>  drivers/net/ethernet/freescale/fec.h      |  10 +-
>>>  drivers/net/ethernet/freescale/fec_main.c | 410 ++++++++++++++++------------
>>> --
>>>  2 files changed, 218 insertions(+), 202 deletions(-)
>>>
>>> --
>>> 2.5.0
>>
