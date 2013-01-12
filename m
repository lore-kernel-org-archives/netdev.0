From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next] be2net: fix unconditionally returning
 IRQ_HANDLED in INTx
Date: Sat, 12 Jan 2013 16:29:36 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C0F1F0CD6@RVEXMB1.ad.emulex.com>
References: <ac9920f8-3e7c-4920-8323-510e648822c8@CMEXHTCAS2.ad.emulex.com>
 <20130112.012146.1746775070657245621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:10729 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab3ALQ3i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 11:29:38 -0500
In-Reply-To: <20130112.012146.1746775070657245621.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>
>From: Sathya Perla <sathya.perla@emulex.com>
>Date: Sat, 12 Jan 2013 14:17:02 +0530
>
>> commit e49cc34f introduced an unconditional IRQ_HANDLED return in be_intx()
>> to workaround Lancer and BE2 HW issues. This is bad as it prevents the kernel
>> from detecting interrupt storms due to broken HW.
>>
...
>> Issue (1) can cause the notified events to be orphaned, if NAPI was already
>> running.
>> This patch fixes this issue by scheduling NAPI only if it is not scheduled
>> already. Doing this also takes care of possible events_get() race that may be
>> caused due to issue (2) and (3). Also, IRQ_HANDLED is returned only the first
>> time zero events are detected.
>> (Thanks Ben H. for the feedback and suggestions.)
>>
>> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
>
>Any particular reason why we shouldn't put this fix into 'net' instead
>of 'net-next'?

Dave, this fix can surely go into "net" as the previous commit is already in Linus tree....
I guess I requested "net-next" just out of habit.

thanks,
-Sathya 
