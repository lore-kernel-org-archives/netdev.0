From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: TI CPSW Ethernet Tx performance regression
Date: Tue, 4 Feb 2014 14:16:22 +0530
Message-ID: <52F0A8DE.8080302@ti.com>
References: <1389790129-5721-1-git-send-email-mugunthanvnm@ti.com> <1389808467.11912.9.camel@bwh-desktop.uk.level5networks.com> <CAGVrzca+jeetqMbQ8NvVgddrjEuay+GWZjZadekV2-AiE4OLyw@mail.gmail.com> <52D77716.1020205@ti.com> <CAGVrzcY5jm+1+B1eqn4Li8K6ovDHCfKwuddqXHgLy_gFNs1KuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:40972 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310AbaBDIqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Feb 2014 03:46:34 -0500
In-Reply-To: <CAGVrzcY5jm+1+B1eqn4Li8K6ovDHCfKwuddqXHgLy_gFNs1KuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Tuesday 04 February 2014 12:54 AM, Florian Fainelli wrote:
> Ok,the priv pointer when we enter the interrupt handler could point to
> e.g: slave 0, so we need to get it re-assigned to the second slave
> using cpsw_get_slave_priv(). How do you ensure that "priv" at the
> beginning of the interrupt handler does not already point to slave 1?
> In that case, is not there a chance to starve slave 0, or at least
> cause an excessive latency by exiting the interrupt handler for slave
> 1, and then re-entering it for slave 0?

devm_request_irq is called with slave 0 priv, so at the beginning of the
interrupt it is always slave 0 priv irrespective whether the slave 0
interface is up or not.

Regards
Mugunthan V N
