From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Tue, 22 Oct 2013 10:09:00 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B739B@saturn3.aculab.com>
References: <20131022.025038.1046903740187748879.davem@davemloft.net> <1382431715-3128-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Antonio Quartulli" <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43346 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751000Ab3JVJLP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 05:11:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02095-09 for <netdev@vger.kernel.org>;
 Tue, 22 Oct 2013 10:11:12 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1382431715-3128-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
> 
> Right now skb->data is passed to rx_hook() even if the skb
> has not been linearised and without giving rx_hook() a way
> to linearise it.
> 
> Change the rx_hook() interface and make it accept the skb
> as argument. In this way users implementing rx_hook() can
> perform all the needed operations to properly (and safely)
> access the skb data.
...
> -	void (*rx_hook)(struct netpoll *, int, char *, int);
> +	void (*rx_hook)(struct netpoll *np, struct sk_buff *skb, int offset);

You can't do that change without changing the way that hooks are registered
so that any existing modules will fail to register their hooks.

	David
