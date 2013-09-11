From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix smatch warning in
 sctp_send_asconf_del_ip
Date: Wed, 11 Sep 2013 16:14:10 -0400 (EDT)
Message-ID: <20130911.161410.1998911877567746536.davem@davemloft.net>
References: <1378579881-27881-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com, micchie@sfc.wide.ad.jp
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab3IKUOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:14:12 -0400
In-Reply-To: <1378579881-27881-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat,  7 Sep 2013 20:51:21 +0200

> This was originally reported in [1] and posted by Neil Horman [2], he said:
> 
>   Fix up a missed null pointer check in the asconf code. If we don't find
>   a local address, but we pass in an address length of more than 1, we may
>   dereference a NULL laddr pointer. Currently this can't happen, as the only
>   users of the function pass in the value 1 as the addrcnt parameter, but
>   its not hot path, and it doesn't hurt to check for NULL should that ever
>   be the case.
> 
> The callpath from sctp_asconf_mgmt() looks okay. But this could be triggered
> from sctp_setsockopt_bindx() call with SCTP_BINDX_REM_ADDR and addrcnt > 1
> while passing all possible addresses from the bind list to SCTP_BINDX_REM_ADDR
> so that we do *not* find a single address in the association's bind address
> list that is not in the packed array of addresses. If this happens when we
> have an established association with ASCONF-capable peers, then we could get
> a NULL pointer dereference as we only check for laddr == NULL && addrcnt == 1
> and call later sctp_make_asconf_update_ip() with NULL laddr.
> 
> BUT: this actually won't happen as sctp_bindx_rem() will catch such a case
> and return with an error earlier. As this is incredably unintuitive and error
> prone, add a check to catch at least future bugs here. As Neil says, its not
> hot path. Introduced by 8a07eb0a5 ("sctp: Add ASCONF operation on the
> single-homed host").
> 
>  [1] http://www.spinics.net/lists/linux-sctp/msg02132.html
>  [2] http://www.spinics.net/lists/linux-sctp/msg02133.html
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable.
