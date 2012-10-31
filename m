From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/9] net: xfrm: use this_cpu_ptr per-cpu helper
Date: Wed, 31 Oct 2012 17:35:46 +0000
Message-ID: <0000013ab7e4a640-60bd5b38-a1fc-4730-b918-4109211ffea0-000000@email.amazonses.com>
References: <509109F9.3030904@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509109F9.3030904@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2012, Shan Wei wrote:

> -
>  	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
>  		struct crypto_comp *tfm;
>
>  		tfms = pos->tfms;
> -		tfm = *per_cpu_ptr(tfms, cpu);
> +
> +		/* This can be any valid CPU ID so we don't need locking. */
> +		tfm = *this_cpu_ptr(tfms);

It would be better to use

	this_cpu_read(tfms)

since that would also make it atomic vs interrupts. The above code (both
original and modified) could determine a pointer to a per cpu structure
and then take an interrupt which would move the task. On return we would
be accessing the per cpu variable of another processor.
