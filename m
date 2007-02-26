From: David Miller <davem@davemloft.net>
Subject: Re: [BUG][2.6.21] af_key: kernel BUG at net/core/skbuff.c:93
Date: Mon, 26 Feb 2007 15:21:15 -0800 (PST)
Message-ID: <20070226.152115.25475996.davem@davemloft.net>
References: <20070226220841.GA7727@dreamland.darkstar.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kronos.it@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161403AbXBZXVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 18:21:17 -0500
In-Reply-To: <20070226220841.GA7727@dreamland.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luca Tettamanti <kronos.it@gmail.com>
Date: Mon, 26 Feb 2007 23:08:41 +0100

> skb_over_panic: text:f1b8a065 len:16 put:16 head:b1a3ba00 data:b1a3ba00 tail:b1a
> 3ba00 end:b1a3ba90 dev:<NULL>

This panic message doesn't make any sense, it should not have
triggered.  skb_put() calls skb_over_panic() when:

	if (unlikely(skb->tail>skb->end))
		skb_over_panic(skb, len, current_text_addr());

but from the panic message it says:

tail:b1a3ba00
end:b1a3ba90

tail is certainly not greater than end.
