From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
Date: Fri, 26 Oct 2012 22:16:39 -0400
Message-ID: <508B4407.7070300@gmail.com>
References: <20121026132422.GA25087@hmsreliant.think-freely.org> <508AE08B.8070303@gmail.com> <20121026203504.GD25087@hmsreliant.think-freely.org> <20121026.171019.702275326710216395.davem@davemloft.net> <20121027014249.GA4008@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50873 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758292Ab2J0CQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 22:16:42 -0400
In-Reply-To: <20121027014249.GA4008@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/2012 09:42 PM, Neil Horman wrote:
> On Fri, Oct 26, 2012 at 05:10:19PM -0400, David Miller wrote:
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Fri, 26 Oct 2012 16:35:04 -0400
>>
>>> On Fri, Oct 26, 2012 at 03:12:11PM -0400, Vlad Yasevich wrote:
>>>> Look at commit 19c7e9ee that introduced this.  I don't remember all
>>>> the details any more, but the problem only occurred on ia64
>>>> (probably due its speculative load handling).
>>>>
>>>> -vlad
>>>>
>>> Thanks Vlad, I'll have a look see.
>>
>> Ok, so this IA64 issue is all about accesses to uninitialized memory.
>>
>> I think Neil's change is thus the most desirable thing to do.  Simple
>> memset the object to zero.
>>
>> Let the compiler optimize or not optimize things as it sees fit, to
>> make sure the object is completely initialized.
>>
>> memset() expands to __builtin_memset(), and therefore the compiler
>> can and will eliminate initializations to overlapping areas if such
>> eliminations are possible.
>>
> If thats the case, then I'll need to duplicate the memset in all three call
> sites.  I've got a busy weekend comming up, but I'll respin this monday barring
> no objections or counter-arguments
>
> Best
> Neil
>

Yes, it should be done in all 3 call sights.  If you are going with 
memset, you can remove .zero element as well.

-vlad
