From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/4] ctc / netiucv: consolidate fsm_action_nop
Date: Thu, 7 Feb 2008 01:26:21 -0500
Message-ID: <20080207062621.GA27498@infradead.org>
References: <20080206182723.103842000@linux.vnet.ibm.com> <20080206183021.700790000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, Peter Tiedemann <ptiedem@de.ibm.com>
To: Ursula Braun <braunu@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40273 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753935AbYBGG00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 01:26:26 -0500
Content-Disposition: inline
In-Reply-To: <20080206183021.700790000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 07:27:24PM +0100, Ursula Braun wrote:
> +/**
> + * NOP action for statemachines
> + */
> +static inline void
> +fsm_action_nop(fsm_instance *fi, int event, void *arg)
> +{
> +}

This is put into a method table, which means taking the address of it.
So marking this inline doesn't make much sense, it should be out of
line somewhere in common code.

>  static struct device_driver netiucv_driver = {
> +	.owner = THIS_MODULE,
>  	.name = "netiucv",
>  	.bus  = &iucv_bus,


This is uncodumented in the changelog and completely unrelated
to the other change in here.

