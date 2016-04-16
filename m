From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vlan: pull on __vlan_insert_tag error path and
 fix csum correction
Date: Fri, 15 Apr 2016 23:20:49 -0400 (EDT)
Message-ID: <20160415.232049.1582872962762792747.davem@davemloft.net>
References: <bde2d4bf994b57e3ca25960d4b347212c8077ac6.1460765959.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbcDPDUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 23:20:55 -0400
In-Reply-To: <bde2d4bf994b57e3ca25960d4b347212c8077ac6.1460765959.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 16 Apr 2016 02:27:58 +0200

> When __vlan_insert_tag() fails from skb_vlan_push() path due to the
> skb_cow_head(), we need to undo the __skb_push() in the error path
> as well that was done earlier to move skb->data pointer to mac header.
> 
> Moreover, I noticed that when in the non-error path the __skb_pull()
> is done and the original offset to mac header was non-zero, we fixup
> from a wrong skb->data offset in the checksum complete processing.
> 
> So the skb_postpush_rcsum() really needs to be done before __skb_pull()
> where skb->data still points to the mac header start and thus operates
> under the same conditions as in __vlan_insert_tag().
> 
> Fixes: 93515d53b133 ("net: move vlan pop/push functions into common code")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  v1 -> v2:
>    - Resend/code still the same, Jiri gave it a review as well meanwhile.

Applied and queued up for -stable, thanks Daniel.
