From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: Converted synclink drivers to use netif_carrier_*()
Date: Sun, 16 Jul 2006 14:23:49 +0200
Message-ID: <m3zmf9love.fsf@defiant.localdomain>
References: <m3veq3suve.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58781 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751527AbWGPMXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2006 08:23:52 -0400
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
In-Reply-To: <m3veq3suve.fsf@defiant.localdomain> (Krzysztof Halasa's message of "Tue, 11 Jul 2006 23:18:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WAN: Converted synclink drivers to use netif_carrier_*() instead
of hdlc_set_carrier().

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index 0721345..bdd09d9 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -1174,8 +1174,12 @@ static void dcd_change(MGSLPC_INFO *info
 	else
 		info->input_signal_events.dcd_down++;
 #ifdef CONFIG_HDLC
-	if (info->netcount)
-		hdlc_set_carrier(info->serial_signals & SerialSignal_DCD, info->netdev);
+	if (info->netcount) {
+		if (info->serial_signals & SerialSignal_DCD)
+			netif_carrier_on(info->netdev);
+		else
+			netif_carrier_off(info->netdev);
+	}
 #endif
 	wake_up_interruptible(&info->status_event_wait_q);
 	wake_up_interruptible(&info->event_wait_q);
@@ -4251,8 +4255,10 @@ static int hdlcdev_open(struct net_devic
 	spin_lock_irqsave(&info->lock, flags);
 	get_signals(info);
 	spin_unlock_irqrestore(&info->lock, flags);
-	hdlc_set_carrier(info->serial_signals & SerialSignal_DCD, dev);
-
+	if (info->serial_signals & SerialSignal_DCD)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
 	return 0;
 }
 
diff --git a/drivers/char/synclink.c b/drivers/char/synclink.c
index fee2aca..ecf4786 100644
--- a/drivers/char/synclink.c
+++ b/drivers/char/synclink.c
@@ -1344,8 +1344,12 @@ static void mgsl_isr_io_pin( struct mgsl
 			} else
 				info->input_signal_events.dcd_down++;
 #ifdef CONFIG_HDLC
-			if (info->netcount)
-				hdlc_set_carrier(status & MISCSTATUS_DCD, info->netdev);
+			if (info->netcount) {
+				if (status & MISCSTATUS_DCD)
+					netif_carrier_on(info->netdev);
+				else
+					netif_carrier_off(info->netdev);
+			}
 #endif
 		}
 		if (status & MISCSTATUS_CTS_LATCHED)
@@ -7844,8 +7848,10 @@ static int hdlcdev_open(struct net_devic
 	spin_lock_irqsave(&info->irq_spinlock, flags);
 	usc_get_serial_signals(info);
 	spin_unlock_irqrestore(&info->irq_spinlock, flags);
-	hdlc_set_carrier(info->serial_signals & SerialSignal_DCD, dev);
-
+	if (info->serial_signals & SerialSignal_DCD)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
 	return 0;
 }
 
diff --git a/drivers/char/synclink_gt.c b/drivers/char/synclink_gt.c
index b4d1f4e..03f5cdf 100644
--- a/drivers/char/synclink_gt.c
+++ b/drivers/char/synclink_gt.c
@@ -1497,8 +1497,10 @@ static int hdlcdev_open(struct net_devic
 	spin_lock_irqsave(&info->lock, flags);
 	get_signals(info);
 	spin_unlock_irqrestore(&info->lock, flags);
-	hdlc_set_carrier(info->signals & SerialSignal_DCD, dev);
-
+	if (info->signals & SerialSignal_DCD)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
 	return 0;
 }
 
@@ -1997,8 +1999,12 @@ static void dcd_change(struct slgt_info 
 		info->input_signal_events.dcd_down++;
 	}
 #ifdef CONFIG_HDLC
-	if (info->netcount)
-		hdlc_set_carrier(info->signals & SerialSignal_DCD, info->netdev);
+	if (info->netcount) {
+		if (info->signals & SerialSignal_DCD)
+			netif_carrier_on(info->netdev);
+		else
+			netif_carrier_off(info->netdev);
+	}
 #endif
 	wake_up_interruptible(&info->status_event_wait_q);
 	wake_up_interruptible(&info->event_wait_q);
diff --git a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
index 8587401..9681255 100644
--- a/drivers/char/synclinkmp.c
+++ b/drivers/char/synclinkmp.c
@@ -1753,8 +1753,10 @@ static int hdlcdev_open(struct net_devic
 	spin_lock_irqsave(&info->lock, flags);
 	get_signals(info);
 	spin_unlock_irqrestore(&info->lock, flags);
-	hdlc_set_carrier(info->serial_signals & SerialSignal_DCD, dev);
-
+	if (info->serial_signals & SerialSignal_DCD)
+		netif_carrier_on(dev);
+	else
+		netif_carrier_off(dev);
 	return 0;
 }
 
@@ -2523,8 +2525,12 @@ void isr_io_pin( SLMP_INFO *info, u16 st
 			} else
 				info->input_signal_events.dcd_down++;
 #ifdef CONFIG_HDLC
-			if (info->netcount)
-				hdlc_set_carrier(status & SerialSignal_DCD, info->netdev);
+			if (info->netcount) {
+				if (status & SerialSignal_DCD)
+					netif_carrier_on(info->netdev);
+				else
+					netif_carrier_off(info->netdev);
+			}
 #endif
 		}
 		if (status & MISCSTATUS_CTS_LATCHED)
