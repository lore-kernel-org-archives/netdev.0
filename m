From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: remove dead inetpeer sequence code
Date: Mon, 08 Sep 2014 16:17:27 -0700
Message-ID: <1410218247.11872.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410217714-26421-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46922 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164AbaIHXR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 19:17:28 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so5777113pad.20
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 16:17:28 -0700 (PDT)
In-Reply-To: <1410217714-26421-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 19:08 -0400, Willem de Bruijn wrote:
> inetpeer sequence numbers are no longer incremented, so no need to
> check and flush the tree. The function that increments the sequence
> number was already dead code and removed in in "ipv4: remove unused
> function" (068a6e18). Remove the code that checks for a change, too.
> 
> Verifying that v4_seq and v6_seq are never incremented and thus that
> flush_check compares bp->flush_seq to 0 is trivial.
> 
> The second part of the change removes flush_check completely even
> though bp->flush_seq is exactly !0 once, at initialization. This
> change is correct because the time this branch is true is when
> bp->root == peer_avl_empty_rcu, in which the branch and
> inetpeer_invalidate_tree are a NOOP.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
