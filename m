From: Ming Liu <ming.liu@windriver.com>
Subject: Re: [PATCH] crypto: aesni-intel - avoid IPsec re-ordering
Date: Thu, 13 Nov 2014 09:53:39 +0800
Message-ID: <54640F23.7070509@windriver.com>
References: <1415771371-30774-1-git-send-email-ming.liu@windriver.com> <20141112084138.GL6390@secunet.com> <54633958.2080705@windriver.com> <20141112114859.GO6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<ying.xue@windriver.com>, <linux-crypto@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39688 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbaKMBxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 20:53:53 -0500
In-Reply-To: <20141112114859.GO6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2014 07:48 PM, Steffen Klassert wrote:
> On Wed, Nov 12, 2014 at 06:41:28PM +0800, Ming Liu wrote:
>> On 11/12/2014 04:41 PM, Steffen Klassert wrote:
>>> On Wed, Nov 12, 2014 at 01:49:31PM +0800, Ming Liu wrote:
>>>>   }
>>>> @@ -147,11 +149,9 @@ static void cryptd_queue_worker(struct work_struct *work)
>>>>   	preempt_disable();
>>>>   	backlog = crypto_get_backlog(&cpu_queue->queue);
>>>>   	req = crypto_dequeue_request(&cpu_queue->queue);
>>>> -	preempt_enable();
>>>> -	local_bh_enable();
>>> Everything below the local_bh_enable() should not run in atomic context
>>> as the subsequent functions may set the CRYPTO_TFM_REQ_MAY_SLEEP flag.
>> If I turn off all the CRYPTO_TFM_REQ_MAY_SLEEP in cryptd.c, is that
>> going to work?
> Well, this might make the cryptd function accessible in atomic context,
> but it does not solve the other problems with this approach. Also,
> cryptd can be used to move requests out of atomic context and I think
> it should stay as it is.

OK, got it. Thanks for the information.

the best,
thank you
>
>
