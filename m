From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario
 which now beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 09:26:25 +0100
Message-ID: <52610CD202000078000FC00B@nat28.tlf.novell.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com>
 <525FBB4F02000078000FBB30@nat28.tlf.novell.com>
 <525FA79F.8060601@oracle.com>
 <525FC98002000078000FBBB5@nat28.tlf.novell.com>
 <52601274.5010008@oracle.com>
 <526102DE02000078000FBFBB@nat28.tlf.novell.com>
 <5260EDD8.4020608@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	"jianhai luan" <jianhai.luan@oracle.com>, <netdev@vger.kernel.org>
To: "annie li" <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:47981 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3JRI03 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Fri, 18 Oct 2013 04:26:29 -0400
In-Reply-To: <5260EDD8.4020608@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 18.10.13 at 10:14, annie li <annie.li@oracle.com> wrote:

> On 2013-10-18 15:43, Jan Beulich wrote:
>>>>> On 17.10.13 at 18:38, annie li <annie.li@oracle.com> wrote:
>>> On 2013-10-17 17:26, Jan Beulich wrote:
>>>>> Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond
>>>>> MAX_ULONG/2 in 64-bit will need long long time)
>>>>>
>>>>> I think the gap should be think all environment even now extending 480+.
>>>>> if now fall in the gap,  one timer will be pending and replenish will be
>>>>> in time.  Please run the attachment test program.
>>>> Not sure what this is supposed to tell me. I recognize that there
>>>> are overflow conditions not handled properly, but (a) I have a
>>>> hard time thinking of a sensible guest that sits idle for over 240
>>>> days (host uptime usually isn't even coming close to that due to
>>>> maintenance requirements) and (b) if there is such a sensible
>>>> guest, then I can't see why dealing with one being idle for over
>>>> 480 days should be required too.
>>>>
>>> If the guest contains multiple NICs, that situation probably happens
>>> when one NIC keeps idle and others work under load. BTW, how do you get
>>> the 240?
>> 2^31 / 100 / 60 / 60 / 24
>>
>> Obviously with HZ=1000 the span would be smaller by a factor
>> of 10, which would make it even more clear that doubling the
>> span doesn't really help.
> 
> My understanding is this patch does not simply double the span, it is 
> just stricter than the original one. Please check my previous comments, 
> I paste it here.

No, the code (on a 32-bit arch) just _can't_ handle jiffies differences
beyond 2^32, no matter how cleverly you use the respective macros.
All arithmetic there is done modulo 2^32.

> ----------expires-------now-------credit----------    is the only case 
> where we need to add a timer.
> 
> Other cases like following would match the if condition above, then no 
> timer is added.
> ----------expires----------credit------now------
> -----now-----expires----------credit----------

The problem with these graphs is that you fail to take the finite
number range (and hence the modulo arithmetic) into account.

Jan
