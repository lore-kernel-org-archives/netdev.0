From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Netlink mmap tx security?
Date: Tue, 16 Dec 2014 16:02:59 -0800
Message-ID: <1418774579.9773.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141014.220908.123550384430402000.davem@davemloft.net>
	 <543F6998.5090000@redhat.com> <20141016070753.GA16738@casper.infradead.org>
	 <20141216.175817.576861457076632402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, dborkman@redhat.com, luto@amacapital.net,
	torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:42153 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaLQADC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 19:03:02 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so13989177iec.36
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 16:03:01 -0800 (PST)
In-Reply-To: <20141216.175817.576861457076632402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-16 at 17:58 -0500, David Miller wrote:

> +		__skb_put(skb, nm_len);
> +		memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, nm_len);
> +		netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
>  

Not related to this patch, but it looks like netlink_set_status()
barrier is wrong ?

It seems we need smp_wmb() after the memcpy() and before the
hdr->nm_status = status; 
