From: Rick Jones <rick.jones2@hp.com>
Subject: Re: sun neptune mis-detecting ethernet crc faults?
Date: Mon, 29 Jun 2009 14:29:06 -0700
Message-ID: <4A493222.4040504@hp.com>
References: <4A492AA1.2020204@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:22462 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbZF2V3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 17:29:05 -0400
In-Reply-To: <4A492AA1.2020204@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Hi all,
> 
> David Miller is busy and suggested someone on the list might be able to
> help.
> 
> We have some boards using the Sun Neptune ethernet adapters.  We're
> seeing behaviour that at this point looks like a hardware glitch
> in the ethernet CRC validation on the receive path.  It appears to be
> incorrectly detecting a corrupt CRC and dropping the frames.  (We've
> enabled port mirroring on the switch and the frames are received without
> errors on the eavesdropper board.)

A simplistic question, but are you sure that the eavesdropper board is 
checking CRCs?

> The odd thing is that we're using a TCP connection and once the CRC
> glitch shows up for a particular chunk of data it continues to drop all
> the retransmissions for that chunk as having bad CRCs, even though their
> CRC values are totally different due to different embedded timestamps.

Do you mean TCP timestamp options?

> Has anyone heard of anything like this on the Neptune hardware? 

Can't say as I have, but the history of "networking" is littered with 
data pattern induced bugs in all manner of hardware.

> MTU is set to 2000 if it matters, though we're planning on retesting
> with it set to 1500.

An MTU of 2000 bytes means a TCP segment with timestamps enabled will be 
2032 plus the ethernet header (assuming no vlan tags) of 14 bytes for 
2046 and then there is the trailing CRC - which is getting very close to 
a magic power of two boundary, another place where history is repleat 
with examples of bugs.  One that comes to mind is that the old Alteon 
AceNICs got very unhappy if one crossed a 4G boundary with a DMA...

rick jones

> 
> I'm considering disabling the hardware CRC check as a
> verification--looking at the niu driver I think I should be able to do
> this by not including XMAC_CONFIG_RX_CRC_CHK_DIS in the big list of
> flags being OR'd in niu_init_rx_xmac().
> 
> Anyone have any suggestions?
> 
> Thanks,
> 
> Chris
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

