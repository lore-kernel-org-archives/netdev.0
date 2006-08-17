From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge crashes
Date: Wed, 16 Aug 2006 20:39:03 -0700
Message-ID: <20060816203903.3a7b1d32@localhost.localdomain>
References: <20060816105752.717c3d86@localhost.localdomain>
	<664E3671B2B6DC439E0C9FFCF8E40CA205F501@exchange.I-BNEX>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Oledzki" <olel@ans.pl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8415 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751274AbWHQDj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 23:39:26 -0400
To: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
In-Reply-To: <664E3671B2B6DC439E0C9FFCF8E40CA205F501@exchange.I-BNEX>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

possible PCI posting bug?

--- linux-2.6.orig/drivers/net/skge.c
+++ linux-2.6/drivers/net/skge.c
@@ -2745,7 +2745,7 @@ static int skge_poll(struct net_device *
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= rxirqmask[skge->port];
   	skge_write32(hw, B0_IMSK, hw->intr_mask);
-	mmiowb();
+	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
 
 	return 0;
@@ -2879,6 +2879,7 @@ static void skge_extirq(void *arg)
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= IS_EXT_REG;
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	skge_read32(hw, B0_IMSK);
 	spin_unlock_irq(&hw->hw_lock);
 }
 
@@ -2953,6 +2954,7 @@ static irqreturn_t skge_intr(int irq, vo
 		skge_error_irq(hw);
 
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	skge_read32(hw, B0_IMSK);
 	spin_unlock(&hw->hw_lock);
 
 	return IRQ_HANDLED;
