From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Wed, 12 Nov 2014 12:48:59 +0100
Message-ID: <20141112114859.GO6390@secunet.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com>
 <20141112084138.GL6390@secunet.com>
 <54633958.2080705@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<ying.xue@windriver.com>, <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Ming Liu <ming.liu@windriver.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54633958.2080705@windriver.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 06:41:28PM +0800, Ming Liu wrote:
> On 11/12/2014 04:41 PM, Steffen Klassert wrote:
> >On Wed, Nov 12, 2014 at 01:49:31PM +0800, Ming Liu wrote:
> >>  }
> >>@@ -147,11 +149,9 @@ static void cryptd_queue_worker(struct work_struct *work)
> >>  	preempt_disable();
> >>  	backlog = crypto_get_backlog(&cpu_queue->queue);
> >>  	req = crypto_dequeue_request(&cpu_queue->queue);
> >>-	preempt_enable();
> >>-	local_bh_enable();
> >Everything below the local_bh_enable() should not run in atomic context
> >as the subsequent functions may set the CRYPTO_TFM_REQ_MAY_SLEEP flag.
> If I turn off all the CRYPTO_TFM_REQ_MAY_SLEEP in cryptd.c, is that
> going to work?

Well, this might make the cryptd function accessible in atomic context,
but it does not solve the other problems with this approach. Also,
cryptd can be used to move requests out of atomic context and I think
it should stay as it is.
