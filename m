From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH][XFRM] Fixes for net-2.6
Date: Wed, 04 Oct 2006 11:08:01 +0900
Message-ID: <45231781.9060409@linux-ipv6.org>
References: <4521D932.8050502@linux-ipv6.org> <20061003.155504.126762903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:63619 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1030705AbWJDCIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 22:08:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061003.155504.126762903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Tue, 03 Oct 2006 12:29:54 +0900
> 
>>     [XFRM] POLICY: Fix per-direction policy counter after flushing.
>>
>>     Currently when xfrm_policy_flush() is called per-direction
>>     policy counter is cleared. However flusing policy is performed
>>     for each type (i.e. main or sub) then it is not always true
>>     to make the counter zero.
>>
>>     Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> The idea of this code is to avoid updating global state many
> many times during such a flush.  This can be expensive and
> cause much SMP cacheline activity as other cpus read the
> counter in the routing lookup path.

Thanks for the clarify. My patch should have included such cacheline
consideration.

> I think what I'll do is reimplement this patch so that a local
> variable is used to maintain how many entries were removed,
> and then simply subtract that counter from xfrm_policy_count[dir]
> at the very end where the assignment to zero occurs.

I feel it's better idea now. I agree to apply it instead of my patch.

Regards,

-- 
Masahide NAKAMURA
