From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: keep original skb ownership
Date: Mon, 06 Jan 2014 16:41:40 -0500 (EST)
Message-ID: <20140106.164140.1492662570549981799.davem@davemloft.net>
References: <1387803413-22152-1-git-send-email-sathya.perla@emulex.com>
	<1389030871.12212.203.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, netdev@vger.kernel.org,
	edumazet@google.com, stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462AbaAFVlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:41:42 -0500
In-Reply-To: <1389030871.12212.203.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jan 2014 09:54:31 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Sathya Perla posted a patch trying to address following problem :
> 
> <quote>
>  The vxlan driver sets itself as the socket owner for all the TX flows
>  it encapsulates (using vxlan_set_owner()) and assigns it's own skb
>  destructor. This causes all tunneled traffic to land up on only one TXQ
>  as all encapsulated skbs refer to the vxlan socket and not the original
>  socket.  Also, the vxlan skb destructor breaks some functionality for
>  tunneled traffic like wmem accounting and as TCP small queues and
>  FQ/pacing packet scheduler.
> </quote>
> 
> I reworked Sathya patch and added some explanations.
> 
> vxlan_xmit() can avoid one skb_clone()/dev_kfree_skb() pair
> and gain better drop monitor accuracy, by calling kfree_skb() when
> appropriate.
> 
> The UDP socket used by vxlan to perform encapsulation of xmit packets
> do not need to be alive while packets leave vxlan code. Its better
> to keep original socket ownership to get proper feedback from qdisc and
> NIC layers.
> 
> We use skb->sk to 
> 
> A) control amount of bytes/packets queued on behalf of a socket, but
> prior vxlan code did the skb->sk transfert without any limit/control
> on vxlan socket sk_sndbuf.
> 
> B) security purposes (as selinux) or netfilter uses, and I do not think
> anything is prepared to handle vxlan stacked case in this area.
> 
> By not changing ownership, vxlan tunnels behave like other tunnels.
> As Stephen mentioned, we might do the same change in L2TP.
> 
> Reported-by: Sathya Perla <sathya.perla@emulex.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks a lot Eric.
