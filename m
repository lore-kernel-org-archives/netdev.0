From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Tue, 29 Jan 2008 21:12:00 +0100
Message-ID: <20080129211200.4fa73063@siona>
References: <1199403419.25262.62.camel@localhost.localdomain>
	<6D762C47-9C9C-422E-A80E-CC418F624B05@freescale.com>
	<479E76A2.8020304@garzik.org>
	<1201622709.12444.118.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:61363 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754889AbYA2UMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 15:12:37 -0500
In-Reply-To: <1201622709.12444.118.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jan 2008 10:05:09 -0600
Nate Case <ncase@xes-inc.com> wrote:

> +/* PHY timer which schedules the state machine work */
> +static void phy_timer(unsigned long data)
> +{
> +	struct phy_device *phydev = (struct phy_device *)data;
> +
> +	/*
> +	 * PHY I/O operations can potentially sleep so we ensure that
> +	 * it's done from a process context
> +	 */
> +	schedule_work(&phydev->state_queue);
> +}

If you use schedule_delayed_work() instead, you can get rid of the
timer.

Haavard
