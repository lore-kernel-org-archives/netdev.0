From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH - regression 4.1-rc8] can: fix loss of CAN frames in raw_rcv
Date: Mon, 22 Jun 2015 12:34:36 +0200
Message-ID: <5587E4BC.3080608@hartkopp.net>
References: <1434905444-11438-1-git-send-email-socketcan@hartkopp.net> <5587DF06.3010509@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Manfred Schlaegl <manfred.schlaegl@gmx.at>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:39713 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933155AbbFVKfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 06:35:09 -0400
In-Reply-To: <5587DF06.3010509@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Manfred,

On 22.06.2015 12:10, Manfred Schlaegl wrote:
> On 2015-06-21 18:50, Oliver Hartkopp wrote:
>> As reported by Manfred Schlaegl here
>>
>>     http://marc.info/?l=linux-netdev&m=143482089824232&w=2
>>
>> commit 514ac99c64b "can: fix multiple delivery of a single CAN frame for
>> overlapping CAN filters" requires the skb->tstamp to be set to check for
>> identical CAN skbs.
>>
>> As net timestamping is influenced by several players (netstamp_needed and
>> netdev_tstamp_prequeue) Manfred missed a proper timestamp which leads to
>> CAN frame loss.
>>
>> As skb timestamping became now mandatory for CAN related skbs this patch
>> makes sure that received CAN skbs always have a proper timestamp set.
>> Maybe there's a better solution in the future but this patch fixes the
>> CAN frame loss so far.
>>
>
> I'm not sure, but maybe this patch (and also my original one) opens a new potential issue with timestamps.
>
> If the timestamp is set at allocation time, this cancels setting the timestamp at delivery (by net_timestamp_check in, for example, netif_receive_skb_internal.) -> So it changes the behavior of timestamping (http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/timestamping.txt?id=b953c0d234bc72e8489d3bf51a276c5c4ec85345) generally.

The only change is that the timestamps for CAN skbs are generated always.
The idea behind the timestamping by user control is to omit the timestamping 
when it's not needed. There's no user visible change in behaviour when the 
timestamp is set in the CAN skbs all time.

> Hypothetical example: If timestamping is enabled by the user and there is a significant delay between allocation and delivery of a skb (early allocation in driver or something) the timestamp does not reflect the reception time anymore.

The change only affects CAN skbs.
These skbs are allocated at CAN frame reception time, filled with content and 
then sent to the network layer.

AFAICS the timestamp becomes more precise for CAN related skbs.
I did not see any case of 'early allocation' in linux/drivers/net/can, did you?

Best regards,
Oliver
