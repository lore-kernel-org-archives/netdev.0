From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Fri, 26 Jan 2007 09:28:38 +0100
Message-ID: <20070126082838.GA1639@ff.dom.local>
References: <45B97763.8000305@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au, mhuth@mvista.com,
	netdev@vger.kernel.org
To: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:47019 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030798AbXAZI0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 03:26:09 -0500
Content-Disposition: inline
In-Reply-To: <45B97763.8000305@ncos.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26-01-2007 04:37, Masayuki Nakagawa wrote:
> This patch simply replaces __kfree_skb() in exit path with kfree_skb().
> In tcp_rcv_state_process(), generally skbs should be destroyed only when
> the ref count is zero.
> That is the way things are supposed to be done in the kernel.
> 
> This change might reveals a memory leak of skb.
> If it happens, it would be because someone doesn't deal with the skb properly.

So maybe for some time there should be added skb->users
test with a warning to reveal this?

Regards,
Jarek P.
