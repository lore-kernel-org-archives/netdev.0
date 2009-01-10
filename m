From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 08/16] dma-debug: add core checking functions
Date: Sun, 11 Jan 2009 00:11:27 +0100
Message-ID: <20090110231127.GK17917@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-9-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756834AbZAJXMX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1231517970-20288-9-git-send-email-joerg.roedel@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +#define err_printk(dev, format, arg...) do {			\
> +		error_count += 1;				\
> +		if (show_all_errors || show_num_errors > 0) {	\
> +			WARN(1, "%s %s: " format,		\
> +			     dev_driver_string(dev),		\
> +			     dev_name(dev) , ## arg);		\
> +		}						\
> +		if (!show_all_errors && show_num_errors > 0)	\
> +			show_num_errors -= 1;			\

Note that the arithmetics here is SMP-unsafe: we only hold the hash bucket 
so if two errors hit at once on two CPUs then the error tracking variables 
can be accessed at once.

I'd suggest a simple global lock for this error case (taken inside the 
hash bucket lock), to be on the safe side.

Also, please dont use a macro for this - printk details can be passed in 
to helper inlines/functions too.

	Ingo
