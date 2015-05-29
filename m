From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Fri, 29 May 2015 09:21:44 +0800
Message-ID: <5567BF28.6050900@windriver.com>
References: <1432801700-29300-1-git-send-email-ying.xue@windriver.com> <1432808028.24345.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:65528 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600AbbE2BVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 21:21:53 -0400
In-Reply-To: <1432808028.24345.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2015 06:13 PM, Eric Dumazet wrote:
> This patch is not needed.
> 
> You really should read Documentation/RCU , because it looks like you are
> quite confused.
> 
> When we remove an element from a RCU protected list, all the objects in
> the chain are already ready to be caught by rcu readers.
> 
> Therefore, no additional memory barrier is needed before doing *np =
> n->next;
> 
> Please do not add spurious memory barriers. Like atomic operations, we
> want all of them being required and possibly documented.


Yes, you are right, thanks for your clear explanation :)
However, there are still three places where we use rcu_assign_pointer() to
remove a neigh entry from a RCU-protected list, and the three places are
neigh_forced_gc(), neigh_flush_dev(), and __neigh_for_each_release()
respectively. This means it's redundant for us to use rcu_assign_pointer() in
the three places, right?

Regards,
Ying
