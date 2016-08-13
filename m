From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net/sctp: always initialise
 sctp_ht_iter::start_fail
Date: Sat, 13 Aug 2016 15:10:50 -0700 (PDT)
Message-ID: <20160813.151050.1364196940604628961.davem@davemloft.net>
References: <1470988251-18792-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lucien.xin@gmail.com, herbert@gondor.apana.org.au,
	ebiederm@xmission.com, marcelo.leitner@gmail.com,
	stable@vger.kernel.org
To: vegard.nossum@oracle.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1470988251-18792-1-git-send-email-vegard.nossum@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Fri, 12 Aug 2016 09:50:51 +0200

> sctp_transport_seq_start() does not currently clear iter->start_fail on
> success, but relies on it being zero when it is allocated (by
> seq_open_net()).
> 
> This can be a problem in the following sequence:
> 
>     open() // allocates iter (and implicitly sets iter->start_fail = 0)
>     read()
>      - iter->start() // fails and sets iter->start_fail = 1
>      - iter->stop() // doesn't call sctp_transport_walk_stop() (correct)
>     read() again
>      - iter->start() // succeeds, but doesn't change iter->start_fail
>      - iter->stop() // doesn't call sctp_transport_walk_stop() (wrong)
> 
> We should initialize sctp_ht_iter::start_fail to zero if ->start()
> succeeds, otherwise it's possible that we leave an old value of 1 there,
> which will cause ->stop() to not call sctp_transport_walk_stop(), which
> causes all sorts of problems like not calling rcu_read_unlock() (and
> preempt_enable()), eventually leading to more warnings like this:
 ...
> Notice that this is a subtly different stacktrace from the one in commit
> 5fc382d875 ("net/sctp: terminate rhashtable walk correctly").
> 
> Cc: Xin Long <lucien.xin@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Applied and queued up for -stable, thanks.
