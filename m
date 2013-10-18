From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 16:55:11 +0800
Message-ID: <5260F76F.2080508@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com> <52601274.5010008@oracle.com> <526102DE02000078000FBFBB@nat28.tlf.novell.com> <5260EDD8.4020608@oracle.com> <52610CD202000078000FC00B@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, david.vrabel@citrix.com,
	xen-devel@lists.xenproject.org,
	jianhai luan <jianhai.luan@oracle.com>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47849 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641Ab3JRIzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 04:55:33 -0400
In-Reply-To: <52610CD202000078000FC00B@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-18 16:26, Jan Beulich wrote:
>>>> On 18.10.13 at 10:14, annie li <annie.li@oracle.com> wrote:
>> On 2013-10-18 15:43, Jan Beulich wrote:
>>>>>> On 17.10.13 at 18:38, annie li <annie.li@oracle.com> wrote:
>>>> On 2013-10-17 17:26, Jan Beulich wrote:
>>>>>> Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond
>>>>>> MAX_ULONG/2 in 64-bit will need long long time)
>>>>>>
>>>>>> I think the gap should be think all environment even now extending 480+.
>>>>>> if now fall in the gap,  one timer will be pending and replenish will be
>>>>>> in time.  Please run the attachment test program.
>>>>> Not sure what this is supposed to tell me. I recognize that there
>>>>> are overflow conditions not handled properly, but (a) I have a
>>>>> hard time thinking of a sensible guest that sits idle for over 240
>>>>> days (host uptime usually isn't even coming close to that due to
>>>>> maintenance requirements) and (b) if there is such a sensible
>>>>> guest, then I can't see why dealing with one being idle for over
>>>>> 480 days should be required too.
>>>>>
>>>> If the guest contains multiple NICs, that situation probably happens
>>>> when one NIC keeps idle and others work under load. BTW, how do you get
>>>> the 240?
>>> 2^31 / 100 / 60 / 60 / 24
>>>
>>> Obviously with HZ=1000 the span would be smaller by a factor
>>> of 10, which would make it even more clear that doubling the
>>> span doesn't really help.
>> My understanding is this patch does not simply double the span, it is
>> just stricter than the original one. Please check my previous comments,
>> I paste it here.
> No, the code (on a 32-bit arch) just _can't_ handle jiffies differences
> beyond 2^32, no matter how cleverly you use the respective macros.
> All arithmetic there is done modulo 2^32.

On 32-bit arch, the jiffies difference beyond 2^32 is only in theory, 
and the real value of jiffies would wrap around after 2^32. Then it will 
still be verified by time_in_range_open, the code will either replenish 
the credit or hit the timer soon.

Thanks
Annie
