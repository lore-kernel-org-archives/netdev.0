From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 5/5] net: sctp: fix incorrect type in gfp initializer
Date: Wed, 11 Jun 2014 17:09:32 +0200
Message-ID: <5398712C.3000801@redhat.com>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com> <1402497297-27100-6-git-send-email-dborkman@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D1725AF78@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434AbaFKPJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 11:09:41 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725AF78@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 04:55 PM, David Laight wrote:
> From: Daniel Borkmann
>> This fixes the following sparse warning:
>>
>>    net/sctp/associola.c:1556:29: warning: incorrect type in initializer (different base types)
>>    net/sctp/associola.c:1556:29:    expected bool [unsigned] [usertype] preload
>>    net/sctp/associola.c:1556:29:    got restricted gfp_t
> ...
>> --- a/net/sctp/associola.c
>> +++ b/net/sctp/associola.c
>> @@ -1591,7 +1591,7 @@ int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
>>   /* Set an association id for a given association */
>>   int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
>>   {
>> -	bool preload = gfp & __GFP_WAIT;
>> +	bool preload = !!(gfp & __GFP_WAIT);
>>   	int ret;
>>
>>   	/* If the id is already assigned, keep it. */
>> --
>
> I was wondering if the compiler still manages to optimise this in a
> manner that avoids actually calculating the boolean value...
>
> So I disassembled the compilation I just did of the old code (gcc 4.7.3).
> The object code looks strange.
> I think that idr_preload_end() must be an empty inline function.

Cc'ing Tejun. ;-)

> The compiler has duplicated the code between the two 'if (preload)'
> clauses (to avoid the conditional test), and the failed to tail
> merge everything in the latter stages.
> I suspect that an empty '#define' would generate smaller code.
>
> 	David
>
>
>
