From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: add the missing sock_owned_by_user check in
 sctp_icmp_redirect
Date: Fri, 20 Oct 2017 12:54:38 +0100 (WEST)
Message-ID: <20171020.125438.333321434362467027.davem@davemloft.net>
References: <7f2a5122d93d4b72115027690e89c0a164097452.1508333869.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        edumazet@google.com, marcelo.leitner@gmail.com,
        nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753044AbdJTLyo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 07:54:44 -0400
In-Reply-To: <7f2a5122d93d4b72115027690e89c0a164097452.1508333869.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 18 Oct 2017 21:37:49 +0800

> Now sctp processes icmp redirect packet in sctp_icmp_redirect where
> it calls sctp_transport_dst_check in which tp->dst can be released.
> 
> The problem is before calling sctp_transport_dst_check, it doesn't
> check sock_owned_by_user, which means tp->dst could be freed while
> a process is accessing it with owning the socket.
> 
> An use-after-free issue could be triggered by this.
> 
> This patch is to fix it by checking sock_owned_by_user before calling
> sctp_transport_dst_check in sctp_icmp_redirect, so that it would not
> release tp->dst if users still hold sock lock.
> 
> Besides, the same issue fixed in commit 45caeaa5ac0b ("dccp/tcp: fix
> routing redirect race") on sctp also needs this check.
> 
> Fixes: 55be7a9c6074 ("ipv4: Add redirect support to all protocol icmp error handlers")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
