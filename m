From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock: ignore SCM_RIGHTS and SCM_CREDENTIALS in
 __sock_cmsg_send
Date: Mon, 11 Jul 2016 13:39:46 -0700 (PDT)
Message-ID: <20160711.133946.466146893193258126.davem@davemloft.net>
References: <1468169506-27038-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slyfox@gentoo.org, soheil@google.com,
	edumazet@google.com, willemb@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbcGKUjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:39:47 -0400
In-Reply-To: <1468169506-27038-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Sun, 10 Jul 2016 12:51:46 -0400

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
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Reported-by: Sergei Trofimovich <slyfox@gentoo.org>
> Tested-by: Sergei Trofimovich <slyfox@gentoo.org>

Please resubmit this with a proper "Fixes: " tag which tells which
commit introduced this regression.
