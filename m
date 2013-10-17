From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] sctp: Do not trigger BUG_ON when deleting assoc without
 primary path
Date: Thu, 17 Oct 2013 20:25:39 +0200
Message-ID: <52602BA3.5020405@redhat.com>
References: <1382031042-27339-1-git-send-email-vyasevich@gmail.com> <526025F2.2040304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Mark Thomas <Mark.Thomas@metaswitch.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762426Ab3JQS0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 14:26:30 -0400
In-Reply-To: <526025F2.2040304@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2013 08:01 PM, Daniel Borkmann wrote:
> On 10/17/2013 07:30 PM, Vlad Yasevich wrote:
>> It is possible to enter sctp_cmd_delete_tcb() without having a
>> primary path.  The situations this most often happens in is
>> when duplication cookie processing is triggered.  In this
>> case, we are deleting a temporarily created association that
>> is not fully populated.   Additially, at the time we
>> are deleting the offending association, it is really too
>> late to issue a BUG!
>>
>> This was introduced by:
>> commit f9e42b853523cda0732022c2e0473c183f7aec65
>>     net: sctp: sideeffect: throw BUG if primary_path is NULL
>
> Sure, lets remove it, but then we could still get a WARN() [sure,
> better than BUG], if the user at the very same time checks procfs
> through sctp_seq_dump_local_addrs(), see discussion we had here [1]:
>
>   It may trigger the crash later if the user performs some action on the
>   association that touches the primary. That's the reason why I was
>   proposing the checks below.
>
>   With the checks in command interpreter, we are only left with the
>   possibility that primary_path changes to NULL during the association
>   lifetime, which code audit doesn't support right now.  If that ever
>   changes we would at least have a bit more information to go on.
>
>   [1] http://patchwork.ozlabs.org/patch/251099/

Meaning, all I'm saying is that with f9e42b853 we wanted to find exactly
such a case we have right now, that is, that an assoc could enter the
hashtable w/o primary path, no?
