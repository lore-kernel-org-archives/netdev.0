From: Rick Jones <rick.jones2@hp.com>
Subject: Re: AW: AW: RFC: replace packets already in queue
Date: Mon, 02 Jul 2012 10:25:56 -0700
Message-ID: <4FF1D9A4.4090504@hp.com>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de> <4FEC854E.8080603@hp.com> <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de> <1340960817.15719.6.camel@edumazet-glaptop> <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de> <1341214310.5269.27.camel@edumazet-glaptop> <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:16612 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212Ab2GBRZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 13:25:59 -0400
In-Reply-To: <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2012 01:38 AM, Erdt, Ralph wrote:
> I did not talking about W-LAN (802.11). I'm talking about an
> property technology which is able to send over KILOMETERs (WLAN <
> 100m) but with VERY low bandwidth: 9600 bit (no Mega, Giga or Kilo!)
> (W-LAN: slowest: 1Mbit). The devices is loosely connected to our
> boxes: No linux driver but a program which create an virtual network
> device. This just sends one packet to the devices and then waits for
> the acknowledgement that the packet was sent. THEN the next packet
> will be send. There is no further queue, because the wireless is so
> lame, that there is no need for that! (BTW: the qdisc and the
> connector are distinct problems/programs. There is no dependency.)

>
>
>> Most packets don't stay in qdisc but are sitting in wireless
>> driver, unless you really flood it. If it happens, you already are
>> in trouble.
>
> We ARE in trouble... :-/

While you may need to tweak some of the constants based on your bitrate
and MTU size (which if the former is 9600 bits per second I trust the
latter is rather smaller than 1500 bytes since that would be well over a
second to transmit... and so the RTT there will be large), it sounds 
like codel will do good things for you.  It won't replace the packet, 
but its use of drop on dequeue will I believe accomplish substantially 
the same effect.

rick jones
