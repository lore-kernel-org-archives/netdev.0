From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix memory leak in auth key management
Date: Tue, 11 Nov 2014 15:20:24 -0500 (EST)
Message-ID: <20141111.152024.1200108289213327921.davem@davemloft.net>
References: <1415638809-20288-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	vyasevich@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbaKKUU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:20:27 -0500
In-Reply-To: <1415638809-20288-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 10 Nov 2014 18:00:09 +0100

> A very minimal and simple user space application allocating an SCTP
> socket, setting SCTP_AUTH_KEY setsockopt(2) on it and then closing
> the socket again will leak the memory containing the authentication
> key from user space:
 ...
> This is bad because of two things, we can bring down a machine from
> user space when auth_enable=1, but also we would leave security sensitive
> keying material in memory without clearing it after use. The issue is
> that sctp_auth_create_key() already sets the refcount to 1, but after
> allocation sctp_auth_set_key() does an additional refcount on it, and
> thus leaving it around when we free the socket.
> 
> Fixes: 65b07e5d0d0 ("[SCTP]: API updates to suport SCTP-AUTH extensions.")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>

Also applied and queued up for -stable, thanks again.
