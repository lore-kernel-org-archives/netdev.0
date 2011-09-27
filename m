From: Jonathan Lallinger <jonathan@opengridcomputing.com>
Subject: Re: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Tue, 27 Sep 2011 12:26:51 -0500
Message-ID: <4E82075B.9000003@opengridcomputing.com>
References: <20110913194101.7497.65515.stgit@build.ogc.int> <20110927.013247.336618301904552114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:59282 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751825Ab1I0R0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 13:26:55 -0400
In-Reply-To: <20110927.013247.336618301904552114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

I am ashamed I made the same mistake twice. This happened because I had=
=20
two git trees (I made a second one when kernel.org went down based off=20
the github remote). I fixed, built, and ran several tests on the patch,=
=20
and then sent the wrong patch from an old git tree (which was never=20
build tested).

I can assure you I have a working patch, and it has been tested by the=20
QA group at Chelsio and it builds/runs but there are still additional=20
bugs in rds. So once I resolve those I will resend the correct patch=20
with some additional fixes.

I am sorry about this and it won't happen again.

Thanks,
  Jonathan

David Miller wrote:
> From: Jonathan Lallinger <jonathan@ogc.us>
> Date: Tue, 13 Sep 2011 14:41:01 -0500
>
>  =20
>> @@ -548,6 +550,7 @@ static int rds_iw_flush_mr_pool(struct rds_iw_mr=
_pool *pool, int free_all)
>>  		spin_unlock_irqrestore(&pool->list_lock, flags);
>>  	}
>> =20
>> +	atomic_sub(unpinned, &poll->free_pinned);
>>  	atomic_sub(ncleaned, &pool->dirty_count);
>>  	atomic_sub(nfreed, &pool->item_count);
>> =20
>>    =20
>
> net/rds/iw_rdma.c: In function =A1rds_iw_flush_mr_pool=A2:
> net/rds/iw_rdma.c:553:24: error: =A1poll=A2 undeclared (first use in =
this function)
> net/rds/iw_rdma.c:553:24: note: each undeclared identifier is reporte=
d only once for each function it appears in
>
> If you didn't even build test it, I know you didn't test it's
> functionality either.
>
> This is crazy.
>
> Well if it's not important enough to even build test this change
> before you post it, then it obviously doesn't matter if the RDMA
> module crashes the kernel when it's unloaded.
>  =20
