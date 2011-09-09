From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Fri, 09 Sep 2011 10:10:58 +0800
Message-ID: <4E6975B2.8000603@intel.com>
References: <4E696FD0.7060702@intel.com> <20110909015429.GA9156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20705 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932543Ab1IICLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 22:11:00 -0400
In-Reply-To: <20110909015429.GA9156@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2011 09:54 AM, Herbert Xu wrote:
> On Fri, Sep 09, 2011 at 09:45:52AM +0800, Yan, Zheng wrote:
>> Hi all,
>>
>> I found a check in tcp_is_sackblock_valid() is suspicious. It against
>> its comment and RFC. I think the correct check should be:
>>
>> ---
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 385c470..a5d01b1 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -1124,7 +1124,7 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
>>                 return 0;
>>  
>>         /* ...Then it's D-SACK, and must reside below snd_una completely */
>> -       if (!after(end_seq, tp->snd_una))
>> +       if (after(end_seq, tp->snd_una))
>>                 return 0;
>>  
>>         if (!before(start_seq, tp->undo_marker))
>> ---
>>
>> I also checked /proc/net/netstat of my laptop, found TCPDSACKIgnoredOld
>> field is not zero. Maybe it's caused by the bug.
> 
> Yes this looks like a typo.  Please resend your patch with a
> description and signed-off-by line.
> 

I think the bug has a big influence on tcp DSACKs. It's better to
leave it to people who fully understand tcp code.

Thanks.
