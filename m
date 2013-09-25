From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] random: introduce
 get_random_bytes_busy_wait_initialized
Date: Wed, 25 Sep 2013 05:06:50 -0700
Message-ID: <1380110810.3165.140.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924054532.GA24446@order.stressinduktion.org>
	 <1380028797.3165.65.camel@edumazet-glaptop>
	 <20130925090034.GC4904@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com, tytso@mit.edu,
	linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130925090034.GC4904@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-25 at 11:00 +0200, Hannes Frederic Sowa wrote:

>  /*
> + * Busy loop until the nonblocking_pool is intialized and return
> + * random data in buf of size nbytes.
> + *
> + * This is used by the network stack to defer the extraction of
> + * entropy from the nonblocking_pool until the pool is initialized.
> + *
> + * We need to busy loop here, because we could be called from an
> + * atomic section.
> + */
> +void get_random_bytes_busy_wait_initialized(void *buf, int nbytes)
> +{
> +	while (!nonblocking_pool.initialized)
> +		cpu_relax();
> +	get_random_bytes(buf, nbytes);
> +}

No idea if this can work if called from IRQ context.

How is nonblocking_poll initialized if host has a single cpu ?
