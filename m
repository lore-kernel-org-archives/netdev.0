From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] Drivers: net: hyperv: Enable scatter gather I/O
Date: Thu, 06 Mar 2014 14:29:19 -0500 (EST)
Message-ID: <20140306.142919.763823800315842610.davem@davemloft.net>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394104390-23477-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Thu,  6 Mar 2014 03:13:05 -0800

> @@ -140,21 +140,125 @@ static void netvsc_xmit_completion(void *context)
>  		dev_kfree_skb_any(skb);
>  }
>  
> +static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
> +			struct hv_page_buffer *pb)
> +{
> +	int j = 0;
> +	/*
> +	 * Deal with compund pages by ignoring unused part
> +	 * of the page.
> +	 */
> +	page += offset  >> PAGE_SHIFT;
> +	offset &= ~PAGE_MASK;

Please put an empty line between local variable declarations and
the code.

Please format comments:

	/* Like
	 * this.
	 */

> +	while (len > 0) {
> +		unsigned long bytes;
> +		bytes = PAGE_SIZE - offset;

Empty line between local variable declarations and code.

> +	/*
> +	 * The packet is laid out thus:
> +	 * 1. hdr
> +	 * 2. skb linear data
> +	 * 3. skb fragment data
> +	 */

Fix comment formatting as explained above.

> +	if (hdr != NULL) {
> +		slots_used += fill_pg_buf(virt_to_page(hdr),
> +					offset_in_page(hdr),
> +					len, &pb[slots_used]);
> +	}

Single statment basic blocks do not need surrounding braces.

> +	/*
> +	 * We will atmost need two pages to describe the rndis
> +	 * header. We can only transmit MAX_PAGE_BUFFER_COUNT number
> +	 * of pages in a single packet.
> +	 */

Comment formatting.
