From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] net: Check the argument for listen(2)
Date: Fri, 28 Jun 2013 11:01:28 -0700
Message-ID: <51CDCF78.90003@hp.com>
References: <1372436577-61749-1-git-send-email-xiaosuo@gmail.com> <1372437203.3301.288.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:44854 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab3F1SBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 14:01:30 -0400
In-Reply-To: <1372437203.3301.288.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2013 09:33 AM, Eric Dumazet wrote:

>
> Well, there is still this possible regression for old applications.
>
> Just use u32 fields instead of u16 ?

FWIW, the manpage for listen() gives the backlog parameter as an "int"

SYNOPSIS
        #include <sys/types.h>          /* See NOTES */
        #include <sys/socket.h>

        int listen(int sockfd, int backlog);

and mentions no explicit limit beyond 2.4.35, only interaction with the 
likes of /proc/sys/net/core/somaxconn.

And sys/socket.h has:

/* Prepare to accept connections on socket FD.
    N connection requests will be queued before further requests are 
refused.
    Returns 0 on success, -1 for errors.  */
extern int listen (int __fd, int __n) __THROW;

Not sure if it is considered "sane" to try to set the backlog to a 
negative value of course...

rick jones
