From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Sun, 13 Feb 2011 21:34:17 +0100
Message-ID: <20110213203417.GA11442@electric-eye.fr.zoreil.com>
References: <AANLkTin7GBSTcfZgr_9sNZ8CPMkW7Vstni+fs2v1-ink@mail.gmail.com> <1297581470.2510.18.camel@edumazet-laptop> <20110213135600.GA11382@electric-eye.fr.zoreil.com> <AANLkTikTw71-mv9WsPT8PxC1a1nwEJ=x0UNDhVQGP1A6@mail.gmail.com> <AANLkTikLOJ-XcwfdbWS19DKzh2s91tn5pQjJe0+CeAN-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ivan Vecera <ivecera@redhat.com>
To: Seblu <seblu@seblu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikLOJ-XcwfdbWS19DKzh2s91tn5pQjJe0+CeAN-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seblu <seblu@seblu.net> :
[...]
> > NIC seems to be reset frequently but host stop rebooting. \o//
> ok after about 1 hour of iperf, host reboot.

Can you apply the patch below on top of 2.6.38-rc4 ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 59ccf0c..5d64b80 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4645,6 +4645,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			switch (tp->mac_version) {
 			/* Work around for rx fifo overflow */
 			case RTL_GIGA_MAC_VER_11:
+			case RTL_GIGA_MAC_VER_20:
 			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_26:
 				netif_stop_queue(dev);
@@ -4653,7 +4654,6 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			/* Testers needed. */
 			case RTL_GIGA_MAC_VER_17:
 			case RTL_GIGA_MAC_VER_19:
-			case RTL_GIGA_MAC_VER_20:
 			case RTL_GIGA_MAC_VER_21:
 			case RTL_GIGA_MAC_VER_23:
 			case RTL_GIGA_MAC_VER_24:
