From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 09:59:20 +0800
Message-ID: <526095F8.7030901@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com> <52601274.5010008@oracle.com> <20131017164127.GA11894@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Beulich <JBeulich@suse.com>,
	jianhai luan <jianhai.luan@oracle.com>,
	david.vrabel@citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32425 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817Ab3JRB7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 21:59:41 -0400
In-Reply-To: <20131017164127.GA11894@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-18 0:41, Wei Liu wrote:
> On Fri, Oct 18, 2013 at 12:38:12AM +0800, annie li wrote:
>> On 2013-10-17 17:26, Jan Beulich wrote:
>>>> Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond
>>>> MAX_ULONG/2 in 64-bit will need long long time)
>>>>
>>>> I think the gap should be think all environment even now extending 480+.
>>>> if now fall in the gap,  one timer will be pending and replenish will be
>>>> in time.  Please run the attachment test program.
>>> Not sure what this is supposed to tell me. I recognize that there
>>> are overflow conditions not handled properly, but (a) I have a
>>> hard time thinking of a sensible guest that sits idle for over 240
>>> days (host uptime usually isn't even coming close to that due to
>>> maintenance requirements) and (b) if there is such a sensible
>>> guest, then I can't see why dealing with one being idle for over
>>> 480 days should be required too.
>>>
>> If the guest contains multiple NICs, that situation probably happens
>> when one NIC keeps idle and others work under load. BTW, how do you
>> get the 240?
>>
> I think Jan got this number with HZ=100. It take ~240 days for jiffies
> to overflow in 32 bit machine when HZ=100.

If HZ is larger then the days would be less, for example, HZ=250, the 
days would be ~99. It is possible to hit overflow in environment where 
multiple NICs coexist and one NIC keeps idle all the time. Moreover, 
this patch does not extend to the days doubled, the timer is set with 
value based on next_credit.

Thanks
Annie
