From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: [PATCH v2 1/2] net: nps_enet: Sync access to packet sent flag
Date: Wed, 27 Apr 2016 15:56:04 +0200
Message-ID: <5720C4F4.3050700@marvell.com>
References: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
 <1461763110-15263-2-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <talz@mellanox.com>,
	<netdev@vger.kernel.org>
To: Elad Kanfi <eladkan@mellanox.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:45845 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbcD0N4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 09:56:14 -0400
In-Reply-To: <1461763110-15263-2-git-send-email-eladkan@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 27.04.2016 15:18, Elad Kanfi wrote:
> From: Elad Kanfi <eladkan@mellanox.com>
>
> Below is a description of a possible problematic
> sequence. CPU-A is sending a frame and CPU-B handles
> the interrupt that indicates the frame was sent. CPU-B
> reads an invalid value of tx_packet_sent.
>
> 	CPU-A				CPU-B
> 	-----				-----
> 	nps_enet_send_frame
> 	.
> 	.
> 	tx_packet_sent = true
> 	order HW to start tx
> 	.
> 	.
> 	HW complete tx
> 			    ------> 	get tx complete interrupt
> 					.
> 					.
> 					if(tx_packet_sent == true)
>
> 	end memory transaction
> 	(tx_packet_sent actually
> 	 written)
>
> Problem solution:
>
> Add a memory barrier after setting tx_packet_sent,
> in order to make sure that it is written before
> the packet is sent.

Should not those SMP memory barriers be paired? AFAIK you do not only have to make sure
that the value written by CPU-A actually is written to memory but also that CPU-B
reads that value from memory. At least this is what I have understood from memory-barriers.txt...

Regards,
Lino
