From: Stefan Agner <stefan@agner.ch>
Subject: Re: ep93xx_eth stopps receiving packages
Date: Mon, 03 May 2010 13:37:20 +0200
Message-ID: <20100503133720.177467vxfhmy1484@limpopo.deheime.ch>
References: <20100419173813.7750395f4fkkmrk0@limpopo.deheime.ch>
	<20100502104350.GS4586@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.deheime.ch ([62.12.167.34]:37261 "EHLO limpopo.deheime.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758039Ab0ECLhY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 07:37:24 -0400
In-Reply-To: <20100502104350.GS4586@mail.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Lennert Buytenhek <buytenh@wantstofly.org>:

> On Mon, Apr 19, 2010 at 05:38:13PM +0200, Stefan Agner wrote:
>
>> I'm using Linux 2.6.32.9 on a technologic systems TS-7250 SBC board, with
>> the ep93xx_eth driver for networking. On three identical, but independent
>> systems I noted that the system is unreachable after a while. On a serial
>> terminal I noted that only the TX counter counts onward, RX stays where it
>> is,
>> no matter if i try to ping from or to the system. Wireshark tells me exactly
>> that too: I see helpless ARP requests which gets answered, but no ICMP. The
>> system doesnt receive the ARP requests, and just sends another one.
>
> (So does the board or does it not respond to ARP requests for its IP?)
The board does not responds to ARP requests for its IP...

>> With a simple program which sends small packages in a fast pace I can
>> reproduce the problem after several seconds (additional CPU load seem to
>> provoke the problem even more). Remove and replug the network cable doesn't
>> solve the problem, but ifup/down does. I don't see any messages in dmesg,
>> memory is still available.
>
> Do you see interrupts increasing in /proc/interrupts when this happens?
No, interrupt doesn't increase anymore when it happens...

I debugged the problem myself inbetween, I just took not the time to format
and send the patch, sorry! There is a bug when interrupts gets disabled for
a longer period, each a frame arrives when one is just been processed.
ep93xx_rx gets called twice then, and the second time marks to many buffers
as relased. I corrected this error by releasing the correct number of buffers
when ep93xx_poll ends... Patch follows!

Stefan


-- 
Stefan Agner

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

