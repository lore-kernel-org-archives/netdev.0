From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: remove NULL check in
 sctp_assoc_update_retran_path
Date: Thu, 13 Mar 2014 13:24:46 -0400 (EDT)
Message-ID: <20140313.132446.1003026026338152564.davem@davemloft.net>
References: <1394718326-6415-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	davej@redhat.com, dan.carpenter@oracle.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbaCMRYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 13:24:48 -0400
In-Reply-To: <1394718326-6415-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 13 Mar 2014 14:45:26 +0100

> This is basically just to let Coverity et al shut up. Remove an
> unneeded NULL check in sctp_assoc_update_retran_path().
> 
> It is safe to remove it, because in sctp_assoc_update_retran_path()
> we iterate over the list of transports, our own transport which is
> asoc->peer.retran_path included. In the iteration, we skip the
> list head element and transports in state SCTP_UNCONFIRMED.
> 
> Such transports came from peer addresses received in INIT/INIT-ACK
> address parameters. They are not yet confirmed by a heartbeat and
> not available for data transfers.
> 
> We know however that in the list of transports, even if it contains
> such elements, it at least contains our asoc->peer.retran_path as
> well, so even if next to that element, we only encounter
> SCTP_UNCONFIRMED transports, we are always going to fall back to
> asoc->peer.retran_path through sctp_trans_elect_best(), as that is
> for sure not SCTP_UNCONFIRMED as per fbdf501c9374 ("sctp: Do no
> select unconfirmed transports for retransmissions").
> 
> Whenever we call sctp_trans_elect_best() it will give us a non-NULL
> element back, and therefore when we break out of the loop, we are
> guaranteed to have a non-NULL transport pointer, and can remove
> the NULL check.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
