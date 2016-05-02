From: Elad Kanfi <eladkan@mellanox.com>
Subject: RE: [PATCH v2 1/2] net: nps_enet: Sync access to packet sent flag
Date: Mon, 2 May 2016 10:21:19 +0000
Message-ID: <HE1PR0501MB2026E62285B397A5C7CC9705CD790@HE1PR0501MB2026.eurprd05.prod.outlook.com>
References: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
	<1461763110-15263-2-git-send-email-eladkan@mellanox.com>
 <20160428.171120.2028974436439452264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Noam Camus <noamca@mellanox.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"abrodkin@synopsys.com" <abrodkin@synopsys.com>,
	Tal Zilcer <talz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Lino Sanfilippo <lsanfil@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160428.171120.2028974436439452264.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, April 29, 2016 12:11 AM
To: Elad Kanfi
Cc: Noam Camus; linux-kernel@vger.kernel.org; abrodkin@synopsys.com; Tal Zilcer; netdev@vger.kernel.org
Subject: Re: [PATCH v2 1/2] net: nps_enet: Sync access to packet sent flag

From: Elad Kanfi <eladkan@mellanox.com>
Date: Wed, 27 Apr 2016 16:18:29 +0300

> From: Elad Kanfi <eladkan@mellanox.com>
> 
> Below is a description of a possible problematic sequence. CPU-A is 
> sending a frame and CPU-B handles the interrupt that indicates the 
> frame was sent. CPU-B reads an invalid value of tx_packet_sent.
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
> Add a memory barrier after setting tx_packet_sent, in order to make 
> sure that it is written before the packet is sent.
> 
> Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
> 
> Acked-by: Noam Camus <noamca@mellanox.com>
>
> Please address the feedback about memory barrier pairing.
>
> Also, for both patches, do not put empty lines between the various tags at the end of the commit message.  They should all be together in one continuous group.

Since this driver handles one frame at a time, I couldn't find a case that requires the paired barrier.

The order of reads is not critical once it is assured that the value is valid.

If there is something I'm missing or for the sake of good order, I can add it. 

Please let me know your opinion on this.

I will remove the empty lines in the commit messages at the next patches version.

Elad.
 
