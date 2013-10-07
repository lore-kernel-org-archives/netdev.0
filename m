From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Mon, 7 Oct 2013 17:20:00 -0400
Message-ID: <20131007212000.GA1596@hmsreliant.think-freely.org>
References: <20131007.155214.2232375975382665567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55497 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab3JGVUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 17:20:09 -0400
Content-Disposition: inline
In-Reply-To: <20131007.155214.2232375975382665567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgive the poor reply format, Dave, I deleted your email (to fast on the
trigger apparently), so I have to reconstruct it.

>> @@ -426,9 +426,12 @@ struct sk_buff {
>>  	char			cb[48] __aligned(8);
>>  
>>  	unsigned long		_skb_refdst;
>> -#ifdef CONFIG_XFRM
>> -	struct	sec_path	*sp;
>> -#endif
>> +
>> +	union {
>> +		struct	sec_path	*sp;
>> +		void 			*accel_priv;
>> +	};
>> +
>
>I'm not %100 sure these two things are really mutually exclusive.
>
>What if bridging ebtables does an input route lookup?  That can
>populate the security path.
>
You are mostly likely right, thats why this is an RFC, I haven't really thought
through that bit fully yet, to be perfectly honest.  I wanted a place for a
pointer to the accelerated data path data to live, and that looked like a
reasonably safe place at the time, but as you point out, its not.  I'll need to
find a better place for it.

>Also, why have you not added this to the usual netdev_ops and
>hw_features?

Thats me experimenting.  I was thinking that origionally this functionality
might be grouped separately, so that we could handle it independently of the
standard network device operations (you might have noticed in v1 of my patch I
had a size_t variable in there, so I thought the separation might be
organizationally nice).  It was also something I was tinkering with for
potential future work to support other data plane accelerators (like the FM6000
switch chip from intel) in a manner that didn't pollute the more typical host network
devices.  Like I said though, just experimenting at the moment....

Regards
Neil
