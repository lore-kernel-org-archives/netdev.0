From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 4/4] bridge: add ability to turn off fdb used
 updates
Date: Fri, 3 Feb 2017 09:30:37 +0100
Message-ID: <45f588fd-bece-647c-5b1e-2c64975e640d@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
 <1485876718-18091-5-git-send-email-nikolay@cumulusnetworks.com>
 <20170202.214737.1978812863222769540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37238 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdBCIaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 03:30:39 -0500
Received: by mail-wm0-f41.google.com with SMTP id v77so16268999wmv.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 00:30:39 -0800 (PST)
In-Reply-To: <20170202.214737.1978812863222769540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/17 03:47, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Tue, 31 Jan 2017 16:31:58 +0100
> 
>> @@ -197,7 +197,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>>  		if (dst->is_local)
>>  			return br_pass_frame_up(skb);
>>  
>> -		dst->used = jiffies;
>> +		if (br->used_enabled)
>> +			dst->used = jiffies;
> 
> Have you tried:
> 
> 	if (dst->used != jiffies)
> 		dst->used = jiffies;
> 
> If that isn't effective, you can tweak the test to decrease the
> granularity of the value.  Basically, if dst->used is within
> 1 HZ of jiffies, don't do the write.
> 
> I suspect this might help a lot, and not require a new bridging
> option.
> 

Yes, I actually have a patch titled "used granularity". :-) I've tested with different
values and it does help but it either needs to be paired with another similar test for
the "updated" field (since they share a write-heavy cache line) or they need to be
in separate cache lines to avoid that dst's source port from causing the load HitM for
all who check the value.

I'll run some more tests and probably go this way for now.

Thanks,
 Nik
