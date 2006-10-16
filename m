From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : Suspicious locking in reqsk_queue_hash_req()
Date: Mon, 16 Oct 2006 13:41:51 -0700 (PDT)
Message-ID: <20061016.134151.71090072.davem@davemloft.net>
References: <20061011.022015.63051509.davem@davemloft.net>
	<200610111511.19028.dada1@cosmosbay.com>
	<200610161100.22549.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60839
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161058AbWJPUlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 16:41:51 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610161100.22549.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 16 Oct 2006 11:00:22 +0200

> While browsing include/net/request_sock.h I found this suspicious locking 
> protecting the SYN table hash table. I think this patch is necessary.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

People get tripped up by this one all the time.

We hold a higher level lock which protects other
inserts from happening, namely the listening socket
lock, it works here like the RTNL semaphore does.

We only need to protect the actual change of the hash
head, as lookups can occur asynchronously and we want
linkage seen by lookups to be consistent.

Alexey likes to do this locking trick a lot.

Feel free to add a comment. :-)

