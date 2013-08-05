From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: esp{4,6}: fix potential MTU calculation
 overflows
Date: Mon, 05 Aug 2013 12:27:23 -0700 (PDT)
Message-ID: <20130805.122723.934034495074719594.davem@davemloft.net>
References: <1375699775-13769-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bpoirier@suse.de,
	steffen.klassert@secunet.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab3HET1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 15:27:24 -0400
In-Reply-To: <1375699775-13769-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  5 Aug 2013 12:49:35 +0200

> Commit 91657eafb ("xfrm: take net hdr len into account for esp payload
> size calculation") introduced a possible interger overflow in
> esp{4,6}_get_mtu() handlers in case of x->props.mode equals
> XFRM_MODE_TUNNEL. Thus, the following expression will overflow
> 
>   unsigned int net_adj;
>   ...
>   <case ipv{4,6} XFRM_MODE_TUNNEL>
>          net_adj = 0;
>   ...
>   return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
>            net_adj) & ~(align - 1)) + (net_adj - 2);
> 
> where (net_adj - 2) would be evaluated as <foo> + (0 - 2) in an unsigned
> context. Fix it by simply removing brackets as those operations here
> do not need to have special precedence.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
