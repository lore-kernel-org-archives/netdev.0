From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Thu, 22 Dec 2011 23:44:51 -0500
Message-ID: <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com> <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44453 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813Ab1LWEo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 23:44:58 -0500
Received: by iaeh11 with SMTP id h11so14502806iae.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 20:44:57 -0800 (PST)
In-Reply-To: <1324613414.2674.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 22, 2011, at 11:10 PM, Eric Dumazet wrote:
>> -		if (count > 1<<30) {
>> +		if (count > INT_MAX)
>> +			return -EINVAL;
>> +		count = roundup_pow_of_two(count);
>> +		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))
> 
> Oh well, you added a bug here, since count is "unsigned int"
> 
> Why mixing INT_MAX in the previous test and ULONG_MAX here ?

The first check (count > INT_MAX) is used to avoid overflowing
roundup_pow_of_two(count), e.g., when count is 0xffffffff.

The second check is to avoid overflowing the size for vmalloc().
It gives a less restrictive upper bound than using INT_MAX/UINT_MAX
on 64-bit platform.

Why do you think it's a bug there?  I agree using two checks looks
ugly though.

- xi
