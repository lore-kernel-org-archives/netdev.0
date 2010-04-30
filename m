From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH linux-next v4 2/2] ixgbe: Example usage of the new IRQ
 affinity_hint callback
Date: Fri, 30 Apr 2010 23:47:59 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004302346030.2951@localhost.localdomain>
References: <20100430214445.3992.41647.stgit@ppwaskie-hc2.jf.intel.com> <20100430214517.3992.92545.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, arjan@linux.jf.intel.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100430214517.3992.92545.stgit@ppwaskie-hc2.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:
> +	for (i = 0; i < num_q_vectors; i++) {
> +		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
> +		/* release the CPU mask memory */
> +		free_cpumask_var(q_vector->affinity_mask);
> +		/* clear the affinity_mask in the IRQ descriptor */
> +		irq_set_affinity_hint(adapter->msix_entries[i].vector, NULL);

Freeing the mask _AFTER_ clearing the hint might be a worthwhile
exercise :)

Thanks,

	tglx
