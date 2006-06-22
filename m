From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2.6.17] s2io driver irq fix
Date: Wed, 21 Jun 2006 21:15:34 -0700
Message-ID: <20060621211534.b740d0f8.akpm@osdl.org>
References: <Pine.GSO.4.10.10606211537540.23949-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, dgc@sgi.com, balbir@in.ibm.com,
	viro@zeniv.linux.org.uk, neilb@suse.de, jblunck@suse.de,
	tglx@linutronix.de, ananda.raju@neterion.com,
	leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	alicia.pena@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32710 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751607AbWFVEQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 00:16:04 -0400
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10606211537540.23949-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Jun 2006 15:50:49 -0400 (EDT)
Ananda Raju <Ananda.Raju@neterion.com> wrote:

> +	if (sp->intr_type == MSI_X) {
> +		int i;
>  
> -				free_irq(vector, arg);
> +		for (i=1; (sp->s2io_entries[i].in_use == MSIX_FLG); i++) {
> +			if (sp->s2io_entries[i].type == MSIX_FIFO_TYPE) {
> +				sprintf(sp->desc[i], "%s:MSI-X-%d-TX",
> +					dev->name, i);
> +				err = request_irq(sp->entries[i].vector,
> +					  s2io_msix_fifo_handle, 0, sp->desc[i],
> +						  sp->s2io_entries[i].arg);

Is it usual to prohibit IRQ sharing with msix?

