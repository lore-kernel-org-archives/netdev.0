From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: 6lowpan: fix lowpan_header_create
 non-compression memcpy call
Date: Sun, 05 Jan 2014 20:25:57 -0500 (EST)
Message-ID: <20140105.202557.550937656683679021.davem@davemloft.net>
References: <1388969150-16041-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, werner@almesberger.net
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaAFBZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 20:25:58 -0500
In-Reply-To: <1388969150-16041-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  6 Jan 2014 01:45:50 +0100

> In function lowpan_header_create(), we invoke the following code
> construct:
> 
>   struct ipv6hdr *hdr;
>   ...
>   hdr = ipv6_hdr(skb);
>   ...
>   if (...)
>     memcpy(hc06_ptr + 1, &hdr->flow_lbl[1], 2);
>   else
>     memcpy(hc06_ptr, &hdr, 4);
> 
> Where the else path of the condition, that is, non-compression
> path, calls memcpy() with a pointer to struct ipv6hdr *hdr as
> source, thus two levels of indirection. This cannot be correct,
> and likely only one level of pointer was intended as source
> buffer for memcpy() here.
> 
> Fixes: 44331fe2aa0d ("IEEE802.15.4: 6LoWPAN basic support")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Looks good, applied, thanks.
