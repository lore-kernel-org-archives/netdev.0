From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] net: xfrm6: silence sparse warning
Date: Wed, 8 Jan 2014 13:55:09 +0800
Message-ID: <52CCE83D.5080909@windriver.com>
References: <1389149801-29011-1-git-send-email-ying.xue@windriver.com> <20140107.224357.1577838150943921013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <steffen.klassert@secunet.com>, <dborkman@redhat.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59548 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031AbaAHFzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 00:55:21 -0500
In-Reply-To: <20140107.224357.1577838150943921013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2014 11:43 AM, David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Wed, 8 Jan 2014 10:56:40 +0800
> 
>> Fix below sparse warning:
>>
>> net/ipv6/xfrm6_state.c:66:26: error: cannot size expression
>  ...
>> -	memset(count, 0, sizeof(count));
>> +	memset(count, 0, sizeof(int) * maxclass);
> 
> I think the fix belongs in sparse, making it respect these two expressions
> as equivalent.
> 
> 

Yes, you are right. Actually the fix just eliminates one 'error' warning
complained from sparse, instead its complete sparse warnings like:

  CHECK   net/ipv6/xfrm6_state.c
net/ipv6/xfrm6_state.c:64:19: warning: Variable length array is used.
net/ipv6/xfrm6_state.c:66:26: error: cannot size expression

But the first warning(ie, warning: Variable length array is used) to be
fixed needs a big change made, so I think it seems unnecessary.
Therefore, I just fix the latter in the patch.

Which action below should I take in next step?

1. I just update the fix commit description as below:

-----
Fix below sparse error:

  CHECK   net/ipv6/xfrm6_state.c
net/ipv6/xfrm6_state.c:66:26: error: cannot size expression
-----

2. Fix the former warning as well in the patch by changing the
allocation of count[] array from static mode to dynamical.

3. Just drop the patch

Please tell me.

Thanks,
Ying
