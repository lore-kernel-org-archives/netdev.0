From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V3 05/16] net: fec: reduce interrupts
Date: Wed, 6 Apr 2016 17:42:47 -0700
Message-ID: <5705AD07.10009@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
 <1459909562-22865-6-git-send-email-troy.kisky@boundarydevices.com>
 <20160406.172008.266926707628676037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com, lznuaa@gmail.com,
	fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36647 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbcDGAmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 20:42:49 -0400
Received: by mail-pf0-f170.google.com with SMTP id e128so43897671pfe.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 17:42:49 -0700 (PDT)
In-Reply-To: <20160406.172008.266926707628676037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/6/2016 2:20 PM, David Miller wrote:
> From: Troy Kisky <troy.kisky@boundarydevices.com>
> Date: Tue,  5 Apr 2016 19:25:51 -0700
> 
>> By clearing the NAPI interrupts in the NAPI routine
>> and not in the interrupt handler, we can reduce the
>> number of interrupts. We also don't need any status
>> variables as the registers are still valid.
>>
>> Also, notice that if budget pkts are received, the
>> next call to fec_enet_rx_napi will now continue to
>> receive the previously pending packets.
>>
>> To test that this actually reduces interrupts, try
>> this command before/after patch
>>
>> cat /proc/interrupts |grep ether; \
>> ping -s2800 192.168.0.201 -f -c1000 ; \
>> cat /proc/interrupts |grep ether
>>
>> For me, before this patch is 2996 interrupts.
>> After patch is 2010 interrupts.
>>
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> 
> I really don't think this is a good idea at all.
> 
> I would instead really rather see you stash away the
> status register values into some piece of software state,
> and then re-read them before you are about to finish a
> NAPI poll cycle.
> 
> 

Sure, that's an easy change. But if a TX int is what caused the interrupt
and masks them, and then a RX packet happens before napi runs, do you want
the TX serviced 1st, or RX ?
