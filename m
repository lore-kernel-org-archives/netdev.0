From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-ipv4] question about arguments position
Date: Thu, 04 May 2017 14:00:15 -0500
Message-ID: <20170504140015.Horde.iqqsROVYuFdJnC6P1dMPyBa@gator4166.hostgator.com>
References: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
 <20170504.124600.627647229351638856.davem@davemloft.net>
 <1493920071.22125.37.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.149.101]:20701 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752374AbdEDTXx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 15:23:53 -0400
Received: from cm5.websitewelcome.com (cm5.websitewelcome.com [108.167.139.22])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id 2CC62B02FF
        for <netdev@vger.kernel.org>; Thu,  4 May 2017 14:00:23 -0500 (CDT)
In-Reply-To: <1493920071.22125.37.camel@perches.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

Quoting Joe Perches <joe@perches.com>:

> On Thu, 2017-05-04 at 12:46 -0400, David Miller wrote:
>> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
>> Date: Thu, 04 May 2017 11:07:54 -0500
>>
>> > While looking into Coverity ID 1357474 I ran into the following piece
>> > of code at net/ipv4/inet_diag.c:392:
>>
>> Because it's been this way since at least 2005, it doesn't matter if
>> the order is correct or not.  What's there is the locked in behavior
>> exposed to userspace and changing it will break things for people.
>
> Adding a few comments around the code about why
> it is this way will help avoid future questions.

In the case of Coverity, I already triaged and documented this issue.  
So people can ignore it in the future.

Regarding the code comments, what about the following patch:

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 3828b3a..7a56641 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -389,6 +389,12 @@ static int sk_diag_fill(struct sock *sk, struct  
sk_buff *skb,
                                   nlmsg_flags, unlh, net_admin);
  }

+/*
+ * Ignore the position of the arguments req->id.idiag_dport and
+ * req->id.idiag_sport in both calls to inet_lookup() and inet6_lookup()
+ * functions, once this is a locked in behavior exposed to user space.
+ * Changing this will break things for people.
+ */
  struct sock *inet_diag_find_one_icsk(struct net *net,
                                      struct inet_hashinfo *hashinfo,
                                      const struct inet_diag_req_v2 *req)

Thanks
