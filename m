From: "Mosler, Martin" <mmo@zuehlke.com>
Subject: AW: [PATCH] net/can/mscan: Enable interrupts when all TX buffers
 are occupied to get notified when they are available again
Date: Mon, 28 Nov 2011 13:59:17 +0000
Message-ID: <C3745E3C7FD07D429C54EB3D7606A5A7677EB2@ZRHEX021.ads.zuehlke.com>
References: <C3745E3C7FD07D429C54EB3D7606A5A7677E7C@ZRHEX021.ads.zuehlke.com>,<4ED38EB1.6030806@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"lucas.demarchi@profusion.mobi" <lucas.demarchi@profusion.mobi>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ED38EB1.6030806@grandegger.com>
Content-Language: de-CH
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> When all TX buffers of the mscan are occupied the network layer is told to stop sending further packets. However the TX interrupts are not enabled and therefore the driver has no chance to tell the network layer when it is ready to accept further packets.
>>
>> Signed-off-by: Martin Mosler <mmo@zuehlke.com>
>>
>> --- linux-2.6/drivers/net/can/mscan/mscan.c.orig    2011-11-28 13:54:29.547850661 +0100
>> +++ linux-2.6/drivers/net/can/mscan/mscan.c 2011-11-28 13:55:52.427849601 +0100
>> @@ -214,6 +214,7 @@ static netdev_tx_t mscan_start_xmit(stru
>>     case 0:
>>         netif_stop_queue(dev);
>>         dev_err(dev->dev.parent, "Tx Ring full when queue awake!\n");
>> +       out_8(&regs->cantier, priv->tx_active);
>>         return NETDEV_TX_BUSY;
>>     case 1:
>>         /*
>
>Hm, did you see the error message. Actually, it should never happen, IIRC.
>
>Wolfgang.

It is in fact a very rare condition, but it was triggered during testing when pulling CAN-HI and CAN-LO lines
to GND and VCC in various combinations to verify how the system is recovering. I am working with a MPC5125 
if this is valuable information. (This was only one issue I ran into, I had to do other modifications for other 
issues as well, but I think they are chip specific, I'll share them in a separate thread if you like).
