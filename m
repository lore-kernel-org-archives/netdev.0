From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: sun neptune mis-detecting ethernet crc faults?
Date: Mon, 29 Jun 2009 16:13:53 -0700
Message-ID: <4A494AB1.7010407@sun.com>
References: <4A492AA1.2020204@nortel.com> <4A493222.4040504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Chris Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:61139 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbZF2XTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 19:19:52 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n5TNJt1S007537
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 16:19:55 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.02 64bit (built Apr 16 2009))
 id <0KM000600WNG1I00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Mon,
 29 Jun 2009 16:19:55 -0700 (PDT)
In-reply-to: <4A493222.4040504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Chris Friesen wrote:
>> Hi all,
>>
>> David Miller is busy and suggested someone on the list might be able to
>> help.
>>
>> We have some boards using the Sun Neptune ethernet adapters. We're
>> seeing behaviour that at this point looks like a hardware glitch
>> in the ethernet CRC validation on the receive path. It appears to be
>> incorrectly detecting a corrupt CRC and dropping the frames. (We've
>> enabled port mirroring on the switch and the frames are received without
>> errors on the eavesdropper board.)
>
> A simplistic question, but are you sure that the eavesdropper board is 
> checking CRCs?
>
>> The odd thing is that we're using a TCP connection and once the CRC
>> glitch shows up for a particular chunk of data it continues to drop all
>> the retransmissions for that chunk as having bad CRCs, even though their
>> CRC values are totally different due to different embedded timestamps.
>
> Do you mean TCP timestamp options?
>
>> Has anyone heard of anything like this on the Neptune hardware?
At Sun, we haven't seen such RX CRC error before.
>
> Can't say as I have, but the history of "networking" is littered with 
> data pattern induced bugs in all manner of hardware.
>
>> MTU is set to 2000 if it matters, though we're planning on retesting
>> with it set to 1500.
>
> An MTU of 2000 bytes means a TCP segment with timestamps enabled will 
> be 2032 plus the ethernet header (assuming no vlan tags) of 14 bytes 
> for 2046 and then there is the trailing CRC - which is getting very 
> close to a magic power of two boundary, another place where history is 
> repleat with examples of bugs. One that comes to mind is that the old 
> Alteon AceNICs got very unhappy if one crossed a 4G boundary with a 
> DMA...

>
> rick jones
>
>>
>> I'm considering disabling the hardware CRC check as a
>> verification--looking at the niu driver I think I should be able to do
>> this by not including XMAC_CONFIG_RX_CRC_CHK_DIS in the big list of
>> flags being OR'd in niu_init_rx_xmac().
That is right.

Regards,
Matheos

>>
>> Anyone have any suggestions?
>>
>> Thanks,
>>
>> Chris
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html

