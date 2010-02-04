From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] qlge: Add watchdog timer.
Date: Thu, 04 Feb 2010 12:29:31 -0800 (PST)
Message-ID: <20100204.122931.189315763.davem@davemloft.net>
References: <1265217853-26959-4-git-send-email-ron.mercer@qlogic.com>
	<20100203.193222.64773800.davem@davemloft.net>
	<20100204200603.GB9938@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47582
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933368Ab0BDU3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 15:29:17 -0500
In-Reply-To: <20100204200603.GB9938@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 4 Feb 2010 12:06:03 -0800

> +static void ql_timer(unsigned long data)
> +{
> +	struct ql_adapter *qdev = (struct ql_adapter *)data;
> +	u32 var = 0;
> +
> +	var = ql_read32(qdev, STS);
> +	if (pci_channel_offline(qdev->pdev)) {
> +		QPRINTK(qdev, IFUP, ERR, "EEH STS = 0x%.08x.\n", var);
> +		return;
> +	}
> +
> +	add_timer(&qdev->timer);
> +}
> +

Did the timer every fire more than once in your testing?

Don't you need to re-setup the expiration period before
adding it again?

Same goes for all of those sequences where you go:

	del_timer_sync(&qdev->timer);

	...

	add_timer(&qdev->timer);

in the patch.
