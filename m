From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix unconditionally returning
 IRQ_HANDLED in INTx
Date: Sat, 12 Jan 2013 15:33:20 -0800 (PST)
Message-ID: <20130112.153320.518217924050728083.davem@davemloft.net>
References: <ac9920f8-3e7c-4920-8323-510e648822c8@CMEXHTCAS2.ad.emulex.com>
	<20130112.012146.1746775070657245621.davem@davemloft.net>
	<CF9D1877D81D214CB0CA0669EFAE020C0F1F0CD6@RVEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448Ab3ALXdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 18:33:20 -0500
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C0F1F0CD6@RVEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Date: Sat, 12 Jan 2013 16:29:36 +0000

>>-----Original Message-----
>>From: David Miller [mailto:davem@davemloft.net]
>>
>>From: Sathya Perla <sathya.perla@emulex.com>
>>Date: Sat, 12 Jan 2013 14:17:02 +0530
>>
>>> commit e49cc34f introduced an unconditional IRQ_HANDLED return in be_intx()
>>> to workaround Lancer and BE2 HW issues. This is bad as it prevents the kernel
>>> from detecting interrupt storms due to broken HW.
>>>
> ...
>>> Issue (1) can cause the notified events to be orphaned, if NAPI was already
>>> running.
>>> This patch fixes this issue by scheduling NAPI only if it is not scheduled
>>> already. Doing this also takes care of possible events_get() race that may be
>>> caused due to issue (2) and (3). Also, IRQ_HANDLED is returned only the first
>>> time zero events are detected.
>>> (Thanks Ben H. for the feedback and suggestions.)
>>>
>>> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
>>
>>Any particular reason why we shouldn't put this fix into 'net' instead
>>of 'net-next'?
> 
> Dave, this fix can surely go into "net" as the previous commit is already in Linus tree....
> I guess I requested "net-next" just out of habit.

Applied to 'net', thanks.
