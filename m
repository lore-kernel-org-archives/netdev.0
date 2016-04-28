From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: nps_enet: Sync access to packet sent flag
Date: Thu, 28 Apr 2016 17:11:20 -0400 (EDT)
Message-ID: <20160428.171120.2028974436439452264.davem@davemloft.net>
References: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
	<1461763110-15263-2-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noamca@mellanox.com, linux-kernel@vger.kernel.org,
	abrodkin@synopsys.com, talz@mellanox.com, netdev@vger.kernel.org
To: eladkan@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461763110-15263-2-git-send-email-eladkan@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elad Kanfi <eladkan@mellanox.com>
Date: Wed, 27 Apr 2016 16:18:29 +0300

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
> 
> Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
> 
> Acked-by: Noam Camus <noamca@mellanox.com>

Please address the feedback about memory barrier pairing.

Also, for both patches, do not put empty lines between the various
tags at the end of the commit message.  They should all be together
in one continuous group.
