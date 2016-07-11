From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] sock: ignore SCM_RIGHTS and SCM_CREDENTIALS in
 __sock_cmsg_send
Date: Mon, 11 Jul 2016 14:37:24 -0700 (PDT)
Message-ID: <20160711.143724.1406029004012671841.davem@davemloft.net>
References: <1468270286-7411-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, edumazet@google.com,
	soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbcGKVh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:37:26 -0400
In-Reply-To: <1468270286-7411-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Mon, 11 Jul 2016 16:51:26 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Sergei Trofimovich reported that pulse audio sends SCM_CREDENTIALS
> as a control message to TCP. Since __sock_cmsg_send does not
> support SCM_RIGHTS and SCM_CREDENTIALS, it returns an error and
> hence breaks pulse audio over TCP.
> 
> SCM_RIGHTS and SCM_CREDENTIALS are sent on the SOL_SOCKET layer
> but they semantically belong to SOL_UNIX. Since all
> cmsg-processing functions including sock_cmsg_send ignore control
> messages of other layers, it is best to ignore SCM_RIGHTS
> and SCM_CREDENTIALS for consistency (and also for fixing pulse
> audio over TCP).
> 
> Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Reported-by: Sergei Trofimovich <slyfox@gentoo.org>
> Tested-by: Sergei Trofimovich <slyfox@gentoo.org>

Applied and queued up for -stable, thanks.
