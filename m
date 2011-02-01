From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 31 Jan 2011 20:35:56 -0800 (PST)
Message-ID: <20110131.203556.193730771.davem@davemloft.net>
References: <AANLkTimWuBfeYPOsOFpTiAGS5uHysevAHiOg0svBQ4zW@mail.gmail.com>
	<AANLkTimz7gx7BAQG8RBswDCxnTuVtt3u+YoBZk8+RgEz@mail.gmail.com>
	<AANLkTikgDsM15DO7u2SP15xx=Y_pg6JdCLrie8ACobJP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, joe@perches.com, dilinger@queued.net,
	ratbert@faraday-tech.com
To: ratbert.chuang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753719Ab1BAEfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 23:35:21 -0500
In-Reply-To: <AANLkTikgDsM15DO7u2SP15xx=Y_pg6JdCLrie8ACobJP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Date: Tue, 1 Feb 2011 11:56:16 +0800

> If I simply allocate a page for each rx ring entry, I still need to allocate
> an skb and copy at least packet header in first page to skb->data. Then
> add the page of rest of payload to skb by skb_fill_page_desc().

You should attach the pages, the use __pskb_pull_tail() to bring in the
headers to the linear skb->data area.

See drivers/net/niu.c:niu_process_rx_pkt().
