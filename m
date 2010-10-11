From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Mon, 11 Oct 2010 19:40:11 +0400
Message-ID: <4CB32FDB.4090001@msgid.tls.msk.ru>
References: <1286810413-30238-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:55977 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241Ab0JKPiI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 11:38:08 -0400
In-Reply-To: <1286810413-30238-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey Vagin wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> commit 068a2de57ddf4f472e32e7af868613c574ad1d88 upstream.
> 
> Non-GSO code drops dst entry for performance reasons, but
> the same is missing for GSO code. Drop dst while cache-hot
> for GSO case too.
> 
> Note: Without this patch the kernel may oops if used bridged veth
> devices. A bridge set skb->dst = fake_dst_ops, veth transfers this skb
> to netif_receive_skb...ip_rcv_finish and it calls dst_input(skb), but
> fake_dst_ops->input = NULL -> Oops

Hmm.  Isn't this the reason for my mysterious OOPSes (jump to
NULL) which I concluded are due to stack overflow?  See f.e.
http://www.spinics.net/lists/netdev/msg142104.html

This started happening when I updated virtio drivers in a windows
virtual machne to the ones which supports GSO, and my config
involves bridging veth devices, and this is where the prob
actually occurs - when doing guest => virtio => tap => bridge => veth
route....

Thanks!

/mjt
