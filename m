From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Fri, 16 Oct 2009 11:37:01 +0200
Message-ID: <20091016093659.GB330@e-circ.dyndns.org>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:16361 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbZJPJhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 05:37:45 -0400
Content-Disposition: inline
In-Reply-To: <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 09:59:31AM +0200, Sascha Hauer wrote:
> The in Kernel driver is far beyond its age. it still does not use
> driver model and its mere presence in the Kernel image prevents
> booting my board. The CS8900 still is in use on some embedded
> boards, so this patch adds an alternative driver to the tree
> designed to replace the old one.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---
>  drivers/net/Kconfig         |   12 +
>  drivers/net/Makefile        |    1 +
>  drivers/net/cirrus-cs89x0.c |  847 +++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 860 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/cirrus-cs89x0.c
[...]
> diff --git a/drivers/net/cirrus-cs89x0.c b/drivers/net/cirrus-cs89x0.c
[...]
> +static void
> +cirrus_set_receive_mode(struct net_device *ndev)
> +{
> +	struct cirrus_priv *priv = netdev_priv(ndev);
> +
> +	spin_lock(&priv->lock);
> +

I found this function causing locking problems.
using spin_lock_irqsave/spin_lock_irqrestore solved them.

Can xxx_set_receive_mode be called with interrupts enabled?
I just want to make sure that I didn't break something elsewhere, and
I don't know ethernet (devices) that well.

Kurt
