From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario
 which now beyond the range time_after_eq().
Date: Thu, 17 Oct 2013 10:26:56 +0100
Message-ID: <525FC98002000078000FBBB5@nat28.tlf.novell.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com>
 <525FBB4F02000078000FBB30@nat28.tlf.novell.com>
 <525FA79F.8060601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<annie.li@oracle.com>, <netdev@vger.kernel.org>
To: "jianhai luan" <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:39891 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab3JQJ1A convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Thu, 17 Oct 2013 05:27:00 -0400
In-Reply-To: <525FA79F.8060601@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 17.10.13 at 11:02, jianhai luan <jianhai.luan@oracle.com> wrote:
> On 2013-10-17 16:26, Jan Beulich wrote:
>>>>> On 16.10.13 at 19:22, Jason Luan <jianhai.luan@oracle.com> wrote:
>>> time_after_eq() only works if the delta is < MAX_ULONG/2.
>>>
>>> If netfront sends at a very low rate, the time between subsequent calls
>>> to tx_credit_exceeded() may exceed MAX_ULONG/2 and the test for
>>> timer_after_eq() will be incorrect.  Credit will not be replenished and
>>> the guest may become unable to send (e.g., if prior to the long gap, all
>>> credit was exhausted).
>>>
>>> We should add the scenario which now beyond next_credit+MAX_UNLONG/2. 
> Because
>>> the fact now must be not before than expire, time_before(now, expire) == 
> true
>>> will verify the scenario.
>>>      time_after_eq(now, next_credit) || time_before (now, expire)
>>>      ==
>>>      !time_in_range_open(now, expire, next_credit)
>> So first of all this must be with a 32-bit netback. And the not
>> coverable gap between activity is well over 240 days long. _If_
>> this really needs dealing with, then why is extending this from
>> 240+ to 480+ days sufficient? I.e. why don't you simply
>> change to 64-bit jiffy values, and use time_after_eq64()?
> 
> Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond 
> MAX_ULONG/2 in 64-bit will need long long time)
> 
> I think the gap should be think all environment even now extending 480+. 
> if now fall in the gap,  one timer will be pending and replenish will be 
> in time.  Please run the attachment test program.

Not sure what this is supposed to tell me. I recognize that there
are overflow conditions not handled properly, but (a) I have a
hard time thinking of a sensible guest that sits idle for over 240
days (host uptime usually isn't even coming close to that due to
maintenance requirements) and (b) if there is such a sensible
guest, then I can't see why dealing with one being idle for over
480 days should be required too.

> If use time_after_eq64(), expire ,next_credit and other member will must 
> be u64.

Exactly - that's what I was telling you to do.

Jan
