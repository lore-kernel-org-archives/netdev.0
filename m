From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] net: ppp: don't call sk_chk_filter twice
Date: Sun, 20 Jul 2014 21:28:58 -0700 (PDT)
Message-ID: <20140720.212858.425286621403273701.davem@davemloft.net>
References: <53C37226.2020106@kristov.de>
	<20140714.161523.399591287185710608.davem@davemloft.net>
	<53C992FA.4040204@kristov.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	paulus@samba.org, isdn@linux-pingi.de
To: develop@kristov.de
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <53C992FA.4040204@kristov.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Schulz <develop@kristov.de>
Date: Fri, 18 Jul 2014 23:34:50 +0200

> Hello!
> 
> Am 15.07.2014 01:15, schrieb David Miller:
>> From: Christoph Schulz <develop@kristov.de>
>> Date: Mon, 14 Jul 2014 08:01:10 +0200
>> 
>>> From: Christoph Schulz <develop@kristov.de>
>>>
>>> Commit 568f194e8bd16c353ad50f9ab95d98b20578a39d ("net: ppp: use
>>> sk_unattached_filter api") causes sk_chk_filter() to be called twice when
>>> setting a PPP pass or active filter. This applies to both the generic PPP
>>> subsystem implemented by drivers/net/ppp/ppp_generic.c and the ISDN PPP
>>> subsystem implemented by drivers/isdn/i4l/isdn_ppp.c. The first call is from
>>> within get_filter().
>>> [...]
>>> For 3.15.x, this proposed change is a bugfix rather than a pure optimization as
>>> in that branch, sk_chk_filter() may replace filter codes by other codes which
>>> are not recognized when executing sk_chk_filter() a second time. So with
>>> 3.15.x, if sk_chk_filter() is called twice, the second invocation may yield
>>> EINVAL (this depends on the filter codes found in the filter to be set, but
>>> because the replacement is done for frequently used codes, this is almost
>>> always the case). The net effect is that setting pass and/or active PPP filters
>>> does not work anymore, since sk_unattached_filter_create() always returns
>>> EINVAL due to the second call to sk_chk_filter(), regardless whether the filter
>>> was originally sane or not.
>>>
>>> Signed-off-by: Christoph Schulz <develop@kristov.de>
>> 
>> Applied, thank you.
> 
> As the commit message says, this patch is a bugfix for the 3.15.y
> branch. However, I don't see it in the netdev stable-queue. Could you
> please add it to -stable for 3.15.y?

Done.
