From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Tue, 15 Oct 2013 22:29:15 +0800
Message-ID: <525D513B.70406@oracle.com>
References: <52590DFE.6080203@oracle.com> <20131014111958.GE11739@zion.uk.xensource.com> <525CAC21.5040202@oracle.com> <1381826609.24708.135.camel@kazak.uk.xensource.com> <525D0C41.2080407@oracle.com> <20131015100624.GB29436@zion.uk.xensource.com> <525D2667.6040102@oracle.com> <20131015125802.GR11739@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	ANNIE LI <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31246 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932524Ab3JOO32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 10:29:28 -0400
In-Reply-To: <20131015125802.GR11739@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-15 20:58, Wei Liu wrote:
> On Tue, Oct 15, 2013 at 07:26:31PM +0800, jianhai luan wrote:
> [...]
>>>>> Can you propose a patch?
>>>> Because credit_timeout.expire always after jiffies, i judge the
>>>> value over the range of time_after_eq() by time_before(now,
>>>> vif->credit_timeout.expires). please check the patch.
>>> I don't think this really fix the issue for you. You still have chance
>>> that now wraps around and falls between expires and next_credit. In that
>>> case it's stalled again.
>> if time_before(now, vif->credit_timeout.expires) is true, time wrap
>> and do operation. Otherwise time_before(now,
>> vif->credit_timeout.expires) isn't true, now -
>> vif->credit_timeout.expires should be letter than ULONG_MAX/2.
>> Because next_credit large than vif->credit_timeout.expires
>> (next_crdit = vif->credit_timeout.expires +
>> msecs_to_jiffies(vif->credit_usec/1000)), the delta between now and
>> next_credit should be in range of time_after_eq().  So
>> time_after_eq() do correctly judge.
>>
> Not sure I understand you. Consider "now" is placed like this:
>
>     expires   now   next_credit
>     ----time increases this direction--->
>
> * time_after_eq(now, next_credit) -> false
> * time_before(now, expires) -> false

If now is placed in above environment, the result will be correct 
(Sending package will be not allowed until next_credit).
* time_after_eq(now, next_credit)  --> false will include two environment:
   expires     now   next_credit
   -----------time increases this direction ---->

Or
   expires      next_credit             next_credit + MAX_LONG/2 now
   -----------time increases this direction ---->


the first environment should be correct to control transmit. the second 
environment is our included environment.

Jason
>
> Then it's stuck again. You're merely narrowing the window, not fixing
> the real problem.
>
> Wei.
>
>> Jason
>>> Wei.
