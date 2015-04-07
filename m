From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: fix xfrm_input/xfrm_tunnel_check oops
Date: Tue, 7 Apr 2015 10:57:32 +0200
Message-ID: <20150407085731.GH20559@secunet.com>
References: <20150402075824.GA2079@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <mike@normi.net>, <netdev@vger.kernel.org>,
	<herbert@gondor.apana.org.au>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60756 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322AbbDGI5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 04:57:36 -0400
Content-Disposition: inline
In-Reply-To: <20150402075824.GA2079@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2015 at 10:58:24AM +0300, Alexey Dobriyan wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=95211
> 
> Commit 70be6c91c86596ad2b60c73587880b47df170a41
> ("xfrm: Add xfrm_tunnel_skb_cb to the skb common buffer") added check
> which dereferences ->outer_mode too early but larval SAs don't have
> this pointer set (yet). So check for tunnel stuff later.
> 
> Mike Noordermeer reported this bug and patiently applied all the debugging.
> 
> Technically this is remote-oops-in-interrupt-context type of thing.
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000034
> IP: [<ffffffff8150dca2>] xfrm_input+0x3c2/0x5a0
> 	...
> [<ffffffff81500fc6>] ? xfrm4_esp_rcv+0x36/0x70
> [<ffffffff814acc9a>] ? ip_local_deliver_finish+0x9a/0x200
> [<ffffffff81471b83>] ? __netif_receive_skb_core+0x6f3/0x8f0
> 	...
> 
> RIP  [<ffffffff8150dca2>] xfrm_input+0x3c2/0x5a0
> Kernel panic - not syncing: Fatal exception in interrupt
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Good catch!

Applied to the ipsec tree, thanks everyone!
