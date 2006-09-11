From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 data corruption (TSO ?)
Date: Sun, 10 Sep 2006 22:18:52 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FB2B@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <1157950410.31071.402.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Segher Boessenkool" <segher@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Linux Kernel list" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964798AbWIKFTF@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1157950410.31071.402.camel@localhost.localdomain>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:

> I've added a wmb() in tw32_rx_mbox() and tw32_tx_mbox() and can still
> reproduce the problem. I've also done a 2 days run without TSO enabled
> without a failure (my test program normally fails after a couple of
> minutes).
> 

Hi Ben,

The code is a bit tricky.  It uses function pointers for the various
register read/write methods.  For the 5780, I believe it will be
assigned a simple writel() and not tg3_write32_tx_mbox().  Can you
double check to make sure you have actually added the wmb()?

It's probably easiest to just add the wmb() in tg3_xmit_dma_bug()
before the tw32_tx_mbox().
