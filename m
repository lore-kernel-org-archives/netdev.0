From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: fix poll callback.
Date: Mon, 02 Mar 2015 22:15:47 -0500 (EST)
Message-ID: <20150302.221547.345365592649851304.davem@davemloft.net>
References: <1425317290-1443-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklauser@distanz.ch, balbi@ti.com,
	w-lkml@lebenslange-mailadresse.de, ebiederm@xmission.com,
	alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425317290-1443-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Mon,  2 Mar 2015 18:28:10 +0100

> In case there was some tx buffer reclaimed and not enough rx packets
> to consume the whole budget, napi_complete would not be called and
> interrupts would be kept disabled, effectively resulting in the
> network core never to call the poll callback again and no rx/tx
> interrupts to be fired either.
> 
> Fix that by taking the tx buffer reclaim work into account in the poll
> callback, and keeping interrupts off only when the budget allowance
> has been exhausted.

First, no signoff, that is required for your patch.

Secondly, we strongly recommend that TX buffer reclaim be not
accounted at all in the poll budget.

Just do all of the TX work, unconditionally, every time the poll
routine is invoked.  Do not add it into the work variable that
gets compared against the budget.  Pretend it took '0' units of
work.
