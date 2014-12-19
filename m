From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Fri, 19 Dec 2014 23:24:14 +0100
Message-ID: <5494A58E.7000000@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com> <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:54746 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbaLSWYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 17:24:20 -0500
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There seem to be various places where GFP_KERNEL could be used instead
of GFP_ATOMIC, e.g.:

> +static int setup_nic_devices(struct octeon_device *octeon_dev)
> +{

> +
> +	sc = kmalloc(sizeof(*sc), GFP_ATOMIC);
> +	if (!sc)
> +		return -ENOMEM;
> +

and

> +static int liquidio_init_nic_module(int octeon_id, void *octeon_dev)
> +{

> +	/* Allocate a soft command to be used to send link status requests
> +	 * to the core app.
> +	 */
> +	sc = kmalloc(sizeof(*sc), GFP_ATOMIC);
> +	if (!sc) {
> +		kfree(ls);
> +		return -ENOMEM;

also

> +/*  Configure interrupt moderation parameters */
> +static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
> +{
> +	struct octeon_soft_command *sc;
> +	struct oct_intrmod_cmd *cmd;
> +	int retval;
> +	struct octeon_device *oct_dev = (struct octeon_device *)oct;
> +	unsigned char *cfg;
> +
> +	/* Alloc soft command */
> +	sc = (struct octeon_soft_command *)
> +	     kmalloc(sizeof(struct octeon_soft_command), GFP_ATOMIC);
> +	if (!sc)
> +		return -ENOMEM;

seems only to be called from process context.

Regards,
Lino
