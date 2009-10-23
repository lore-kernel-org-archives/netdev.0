From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Patch] sctp: remove deprecated SCTP_GET_*_OLD stuffs
Date: Fri, 23 Oct 2009 11:58:34 -0400
Message-ID: <4AE1D2AA.8060200@hp.com>
References: <20091015082849.4605.48311.sendpatchset@localhost.localdomain> <4AE0C64A.9080400@hp.com> <20091022214439.GA2635@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:12595 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbZJWP6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 11:58:34 -0400
In-Reply-To: <20091022214439.GA2635@merkur.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Sam Ravnborg wrote:
> On Thu, Oct 22, 2009 at 04:53:30PM -0400, Vlad Yasevich wrote:
>>> diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
>>> index be2334a..0991f1b 100644
>>> --- a/include/net/sctp/user.h
>>> +++ b/include/net/sctp/user.h
>>> @@ -131,14 +131,6 @@ enum sctp_optname {
>>>  #define SCTP_SOCKOPT_BINDX_REM	SCTP_SOCKOPT_BINDX_REM
>>>  	SCTP_SOCKOPT_PEELOFF, 	/* peel off association. */
>>>  #define SCTP_SOCKOPT_PEELOFF	SCTP_SOCKOPT_PEELOFF
>>> -	SCTP_GET_PEER_ADDRS_NUM_OLD, 	/* Get number of peer addresss. */
>>> -#define SCTP_GET_PEER_ADDRS_NUM_OLD	SCTP_GET_PEER_ADDRS_NUM_OLD
>>> -	SCTP_GET_PEER_ADDRS_OLD, 	/* Get all peer addresss. */
>>> -#define SCTP_GET_PEER_ADDRS_OLD	SCTP_GET_PEER_ADDRS_OLD
>>> -	SCTP_GET_LOCAL_ADDRS_NUM_OLD, 	/* Get number of local addresss. */
>>> -#define SCTP_GET_LOCAL_ADDRS_NUM_OLD	SCTP_GET_LOCAL_ADDRS_NUM_OLD
>>> -	SCTP_GET_LOCAL_ADDRS_OLD, 	/* Get all local addresss. */
>>> -#define SCTP_GET_LOCAL_ADDRS_OLD	SCTP_GET_LOCAL_ADDRS_OLD
>>>  	SCTP_SOCKOPT_CONNECTX_OLD, /* CONNECTX old requests. */
>> After running the regression suite against this patch I find that we can't
>> remove the enum values.  Removing the enums changes the value for the remainder
>> of the definitions and breaks binary compatibility for applications that use
>> those trailing options.
>>
>> You should be ok with removing the #defines and actual code that uses them,
>> but not the enums.  You can even rename the enums, but we must preserve
>> numeric ordering.
> 
> If we really depend on the actual value of an enum as in this case,
> then e should assign them direct to better document this.
> 
> 	Sam
> 

I agree.  I have a patch that converts the enum to just a #define section that
I'll apply on top of this removal patch and document the deletion.

-vlad
