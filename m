From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] tcp/dccp: fix inet_reuseport_add_sock()
Date: Thu, 7 Apr 2016 08:18:51 -0600
Message-ID: <57066C4B.6050108@cumulusnetworks.com>
References: <5705A392.2000207@cumulusnetworks.com>
 <1460005654.6473.377.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36102 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756347AbcDGOS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 10:18:57 -0400
Received: by mail-ig0-f180.google.com with SMTP id f1so154486304igr.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 07:18:57 -0700 (PDT)
In-Reply-To: <1460005654.6473.377.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/6/16 11:07 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> David Ahern reported panics in __inet_hash() caused by my recent commit.
>
> The reason is inet_reuseport_add_sock() was still using
> sk_nulls_for_each_rcu() instead of sk_for_each_rcu().
> SO_REUSEPORT enabled listeners were causing an instant crash.
>
> While chasing this bug, I found that I forgot to clear SOCK_RCU_FREE
> flag, as it is inherited from the parent at clone time.
>
> Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> ---

Fixed the problem I as hiting.

Tested-by: David Ahern <dsa@cumulusnetworks.com>
