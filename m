From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [Patch net-next v2 4/4] net: fec: Workaround for imx6sx enet tx
 hang when enable three queues
Date: Tue, 16 Sep 2014 16:24:20 -0500
Message-ID: <CAHrpEqRnFLUSyKk+1-0Os0XgJ0X0aSOsL-mEYpxBPqBem3Zt9A@mail.gmail.com>
References: <1410890290-11248-1-git-send-email-Frank.Li@freescale.com>
	<1410890290-11248-5-git-send-email-Frank.Li@freescale.com>
	<CAOMZO5DnmHBaDr7RzozJoBsuEY=bzmusKcfJQ4NjCyD4+13=Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>,
	Duan Fugang-B38611 <b38611@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:44793 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbaIPVYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 17:24:22 -0400
Received: by mail-la0-f45.google.com with SMTP id b17so650835lan.32
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 14:24:21 -0700 (PDT)
In-Reply-To: <CAOMZO5DnmHBaDr7RzozJoBsuEY=bzmusKcfJQ4NjCyD4+13=Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 3:52 PM, Fabio Estevam <festevam@gmail.com> wrote:
> On Tue, Sep 16, 2014 at 2:58 PM,  <Frank.Li@freescale.com> wrote:
>> From: Fugang Duan <B38611@freescale.com>
>>
>> When enable three queues on imx6sx enet, and then do tx performance
>> test with iperf tool, after some time running, tx hang.
>>
>> Found that:
>>         If uDMA is running, software set TDAR may cause tx hang.
>>         If uDMA is in idle, software set TDAR don't cause tx hang.
>>
>> There is a TDAR race condition for mutliQ when the software sets TDAR
>> and the UDMA clears TDAR simultaneously or in a small window (2-4 cycles).
>> This will cause the udma_tx and udma_tx_arbiter state machines to hang.
>> The issue exist at i.MX6SX enet IP.
>>
>> So, the Workaround is checking TDAR status four time, if TDAR cleared by
>> hardware and then write TDAR, otherwise don't set TDAR.
>>
>> The patch is only one Workaround for the issue TKT210582.
>
> As Shawn pointed out, it is better to use the ERR007885 instead of an
> internal bug numbering.

Sorry, I forget change commit message.

best regards
Frank Li
