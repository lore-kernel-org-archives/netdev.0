From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Wed, 16 Oct 2013 01:48:12 +0400
Message-ID: <525DB81C.6010106@cogentembedded.com>
References: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp> <1381127365-6521-2-git-send-email-nh-ky@jinso.co.jp> <52597FC0.4090801@cogentembedded.com> <Pine.LNX.4.64.1310150926220.5601@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nguyen Hong Ky <nh-ky@jinso.co.jp>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ryusuke Sakato <ryusuke.sakato.bx@renesas.com>,
	Simon Horman <horms@verge.net.au>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:43937 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933657Ab3JOVtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 17:49:15 -0400
Received: by mail-la0-f47.google.com with SMTP id eo20so7297403lab.6
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 14:49:14 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.1310150926220.5601@axis700.grange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/15/2013 11:28 AM, Guennadi Liakhovetski wrote:

>>> This patch will fix RX packets errors when receiving big size
>>> of data by set bit RNC = 1.

>>> RNC - Receive Enable Control

>>> 0: Upon completion of reception of one frame, the E-DMAC writes
>>> the receive status to the descriptor and clears the RR bit in
>>> EDRRR to 0.

>>> 1: Upon completion of reception of one frame, the E-DMAC writes
>>> (writes back) the receive status to the descriptor. In addition,
>>> the E-DMAC reads the next descriptor and prepares for reception
>>> of the next frame.

>>> In addition, for get more stable when receiving packets, I set
>>> maximum size for the transmit/receive FIFO and inserts padding
>>> in receive data.

>>> Signed-off-by: Nguyen Hong Ky <nh-ky@jinso.co.jp>
>>> ---
>>>    drivers/net/ethernet/renesas/sh_eth.c |    4 ++++
>>>    1 files changed, 4 insertions(+), 0 deletions(-)

>>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>>> b/drivers/net/ethernet/renesas/sh_eth.c
>>> index a753928..11d34f0 100644
>>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>>> @@ -649,12 +649,16 @@ static struct sh_eth_cpu_data r8a7740_data = {
>>>    	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
>>>    			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
>>>    			  EESR_TDE | EESR_ECI,
>>> +	.fdr_value	= 0x0000070f,
>>> +	.rmcr_value	= 0x00000001,
>>>
>>>    	.apr		= 1,
>>>    	.mpr		= 1,
>>>    	.tpauser	= 1,
>>>    	.bculr		= 1,
>>>    	.hw_swap	= 1,
>>> +	.rpadir		= 1,
>>> +	.rpadir_value   = 2 << 16,
>>>    	.no_trimd	= 1,
>>>    	.no_ade		= 1,
>>>    	.tsu		= 1,

>>     Guennadi, could you check if this patch fixes your issue with NFS. Make
>> sure it applies to 'r8a7740_data' (it was misapplied to DaveM's tree).

> Yes, the current -next, which includes this patch (in a slightly different
> form) boots fine over NFS for me.

    I don't know what you mean by "slightly different form" exactly. Also, I 
was unable to locate the fresh -next tree. 'net-next.git' contains this patch 
in a mismerged form, 'net.git' has Simon's patch that corrects this mismerge.

> Thanks
> Guennadi

WBR, Sergei
