From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] tipc: validate length of sockaddr in connect() for dgram/rdm
Date: Tue, 24 Mar 2015 17:11:12 +0800
Message-ID: <55112A30.2050800@windriver.com>
References: <1427139003-30510-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<davem@davemloft.net>,
	Allan Stephens <allan.stephens@windriver.com>, open list:
	TIPC NETWORK LAYER <netdev@vger.kernel.org>, ; open list:
	TIPC NETWORK LAYER <tipc-discussion@lists.sourceforge.net>, ;
To: Sasha Levin <sasha.levin@oracle.com>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63965 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbbCXJLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 05:11:41 -0400
In-Reply-To: <1427139003-30510-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2015 03:30 AM, Sasha Levin wrote:
> Commit f2f8036 ("tipc: add support for connect() on dgram/rdm sockets")
> hasn't validated user input length for the sockaddr structure which allows
> a user to overwrite kernel memory with arbitrary input.
> 
> Fixes: f2f8036 ("tipc: add support for connect() on dgram/rdm sockets")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/socket.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index 73c2f51..986dc96 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -1852,6 +1852,8 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
>  		if (dst->family == AF_UNSPEC) {
>  			memset(&tsk->remote, 0, sizeof(struct sockaddr_tipc));
>  			tsk->connected = 0;
> +		} else if (destlen != sizeof(struct sockaddr_tipc)) {
> +			res = -EINVAL;
>  		} else {
>  			memcpy(&tsk->remote, dest, destlen);
>  			tsk->connected = 1;
> 
