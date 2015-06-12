From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: allow authenticating DATA chunks that are
 bundled with COOKIE_ECHO
Date: Fri, 12 Jun 2015 14:18:55 -0700 (PDT)
Message-ID: <20150612.141855.497341688044235937.davem@davemloft.net>
References: <ca8fca62141ed9e108170919cdc12bdb09cdda73.1434043704.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, vyasevich@gmail.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbbFLVS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 17:18:58 -0400
In-Reply-To: <ca8fca62141ed9e108170919cdc12bdb09cdda73.1434043704.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mleitner@redhat.com
Date: Thu, 11 Jun 2015 14:49:46 -0300

> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> Currently, we can ask to authenticate DATA chunks and we can send DATA
> chunks on the same packet as COOKIE_ECHO, but if you try to combine
> both, the DATA chunk will be sent unauthenticated and peer won't accept
> it, leading to a communication failure.
> 
> This happens because even though the data was queued after it was
> requested to authenticate DATA chunks, it was also queued before we
> could know that remote peer can handle authenticating, so
> sctp_auth_send_cid() returns false.
> 
> The fix is whenever we set up an active key, re-check send queue for
> chunks that now should be authenticated. As a result, such packet will
> now contain COOKIE_ECHO + AUTH + DATA chunks, in that order.
> 
> Reported-by: Liu Wei <weliu@redhat.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks.
