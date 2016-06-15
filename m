From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 14 Jun 2016 22:25:16 -0700 (PDT)
Message-ID: <20160614.222516.1192717052949905017.davem@davemloft.net>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davm@davemeloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aligouri@amazon.com, antoine.tenart@free-electrons.com
To: netanel@annapurnalabs.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Netanel Belgazal <netanel@annapurnalabs.com>
Date: Mon, 13 Jun 2016 11:46:13 +0300

> +#define ena_trc_dbg(format, arg...) \
> +	pr_debug("[ENA_COM: %s] " format, __func__, ##arg)
> +#define ena_trc_info(format, arg...) \
> +	pr_info("[ENA_COM: %s] " format, __func__, ##arg)
> +#define ena_trc_warn(format, arg...) \
> +	pr_warn("[ENA_COM: %s] " format, __func__, ##arg)
> +#define ena_trc_err(format, arg...) \
> +	pr_err("[ENA_COM: %s] " format, __func__, ##arg)

These custom tracing macros are quite inappropriate.

We have the function tracer in the kernel when that is needed.  So spitting
out __func__ all over the place is not something that should be found in
drivers these days.

And one can modify pr_fmt do make pr_debug et al. have whatever prefix
one wants.

I suspect there will be several rounds of review to weed out things
like this.  You can preempt a lot of that by removing as much in your
driver that the kernel has existing facilities for.

Thanks.
