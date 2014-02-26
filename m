From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/16] atm: nicstar: remove
 interruptible_sleep_on_timeout
Date: Wed, 26 Feb 2014 11:06:03 -0500 (EST)
Message-ID: <20140226.110603.1107468127601575254.davem@davemloft.net>
References: <1393412516-3762435-1-git-send-email-arnd@arndb.de>
	<1393412516-3762435-11-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393412516-3762435-11-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Feb 2014 12:01:50 +0100

> -		spin_unlock_irqrestore(&scq->lock, flags);
> -		interruptible_sleep_on_timeout(&scq->scqfull_waitq,
> -					       SCQFULL_TIMEOUT);
> -		spin_lock_irqsave(&scq->lock, flags);
> +		wait_event_interruptible_lock_irq_timeout(scq->scqfull_waitq,
> +				scq->tail != scq->next, scq->lock,
> +				SCQFULL_TIMEOUT);
>  

When a function call spans multiple lines, please place arguments for
those function calls starting at the first column after the openning
parenthesis.

Thank you.
