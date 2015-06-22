From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH - regression 4.1-rc8] can: fix loss of CAN frames in raw_rcv
Date: Mon, 22 Jun 2015 17:09:29 +0200
Message-ID: <55882529.7030605@hartkopp.net>
References: <1434905444-11438-1-git-send-email-socketcan@hartkopp.net> <5587DF06.3010509@gmx.at> <5587E4BC.3080608@hartkopp.net> <5587F647.4000105@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Manfred Schlaegl <manfred.schlaegl@gmx.at>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:52534 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbbFVPJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 11:09:45 -0400
In-Reply-To: <5587F647.4000105@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.06.2015 13:49, Manfred Schlaegl wrote:
> On 2015-06-22 12:34, Oliver Hartkopp wrote:
>> On 22.06.2015 12:10, Manfred Schlaegl wrote:
>>> Hypothetical example: If timestamping is enabled by the user and there is a significant delay between allocation and delivery of a skb (early allocation in driver or something) the timestamp does not reflect the reception time anymore.
>>
>> The change only affects CAN skbs.
>> These skbs are allocated at CAN frame reception time, filled with content and then sent to the network layer.
>>
>> AFAICS the timestamp becomes more precise for CAN related skbs.
>> I did not see any case of 'early allocation' in linux/drivers/net/can, did you?
>
> No, I also did not find this case in current driver implementations -- because of that I gave the hypothetical example.
> I just was worried about that this may be a potential latent issue for future driver implementations and wanted to indicate this.
>
> But I trust your expertise, so if you are fine with it, I'm too. ;-)

I don't claim to be 'an expert' :-)

But our usual use-case is CAN logging which enables the timestamping on all 
CAN interfaces anyway - without any problems.

As the timestamp is calculated only once this patch moves the timestamp 
creation closer to the CAN frame arrival time - so latency finally decreases.

Best regards,
Oliver
