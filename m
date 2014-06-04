From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] xen-netback: Fix handling of skbs requiring too
 many slots
Date: Wed, 4 Jun 2014 08:50:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17256EE9@AcuExch.aculab.com>
References: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Zoltan Kiss' <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"paul.durrant@citrix.com" <paul.durrant@citrix.com>,
	"linux@eikelenboom.it" <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51979 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750742AbaFDIvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 04:51:01 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21223-08 for <netdev@vger.kernel.org>;
 Wed,  4 Jun 2014 09:50:51 +0100 (BST)
In-Reply-To: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel.org
> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
> the next BUG_ON a few lines down, as the packet consumes more slots than
> estimated.
> This patch introduces full_coalesce on the skb callback buffer, which is used in
> start_new_rx_buffer() to decide whether netback needs coalescing more
> aggresively. By doing that, no packet should need more than
> XEN_NETIF_MAX_TX_SIZE / PAGE_SIZE data slots, as the provided buffers are fully
> utilized.
...
> -static bool start_new_rx_buffer(int offset, unsigned long size, int head)
> +static bool start_new_rx_buffer(int offset,
> +				unsigned long size,
> +				int head,
> +				bool full_coalesce)

The above is completely incorrect layout ...

...
>  	BUG_ON(size > MAX_BUFFER_OFFSET);
> -	if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
> +	if ((offset + size > MAX_BUFFER_OFFSET) &&
> +	    offset &&
> +	    !head &&
> +	    !full_coalesce)
>  		return true;

As is that.

	David
