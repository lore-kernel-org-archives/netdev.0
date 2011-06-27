From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/9] myri10ge: rework parity error check and cleanup
Date: Mon, 27 Jun 2011 09:01:37 -0700
Message-ID: <1309190497.3344.6.camel@Joe-Laptop>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	 <1309187108-12715-3-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3234 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603Ab1F0QBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 12:01:38 -0400
In-Reply-To: <1309187108-12715-3-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-27 at 10:05 -0500, Jon Mason wrote:
> Clean up watchdog reset code:
>  - unless there is a confirmed h/w fault, verify that a stuck
>    slice is still stuck in the watchdog worker; if the slice is no
>    longer stuck, abort the reset.
[]
> @@ -3498,23 +3536,24 @@ static void myri10ge_watchdog(struct work_struct *work)
[]
> +		if (!reset_needed) {
> +			netdev_err(mgp->dev, "not resetting\n");
> +			return;
> +		}

Probably the wrong level.  Maybe netdev_dbg() or netdev_info()


