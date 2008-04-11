From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] cls_u32: refcounting fix for u32_delete()
Date: Fri, 11 Apr 2008 13:23:04 +0000
Message-ID: <20080411132304.GB2701@ff.dom.local>
References: <20080411124519.GA2701@ff.dom.local> <47FF5FBF.6030802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:63503 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758841AbYDKNUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:20:41 -0400
Received: by fg-out-1718.google.com with SMTP id l27so402001fgb.17
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:20:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47FF5FBF.6030802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 02:55:27PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> [NET_SCHED] cls_u32: refcounting fix for u32_delete()
>>
>> @@ -441,8 +443,10 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
>>  	if (tp->root == ht)
>>  		return -EINVAL;
>>  -	if (--ht->refcnt == 0)
>> +	if (ht->refcnt == 1) {
>> +		ht->refcnt--;
>>  		u32_destroy_hnode(tp, ht);
>> +	}
>>  
>
> Shouldn't the refcount be decremented unconditionally?
> Otherwise I'd suggest to reject the removal if refcnt > 1,
> but silently doing nothing doesn't seem right.

If someone tries deleting and the refcnt is e.g. 3 (2 links)
unconditional deleting could decrease refcnt without deleting
and then unlinking would make it below 0. I think it's OK now:
we can't delete hnode until it's referenced, but I could add
a warning if you like?

Thanks,
Jarek P.
