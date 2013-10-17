From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Thu, 17 Oct 2013 16:25:16 +0100
Message-ID: <5260015C.2030100@citrix.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FAABE.5080806@citrix.com> <525FB9BC.9010608@oracle.com> <525FBC7F.9040800@citrix.com> <525FED42.4040608@oracle.com> <20131017140611.GM16371@zion.uk.xensource.com> <526000F5.1090102@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, Jan Beulich <JBeulich@suse.com>,
	<ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<annie.li@oracle.com>, <netdev@vger.kernel.org>
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:49189 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756745Ab3JQPZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 11:25:49 -0400
In-Reply-To: <526000F5.1090102@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/10/13 16:23, jianhai luan wrote:
> 
> On 2013-10-17 22:06, Wei Liu wrote:
>> On Thu, Oct 17, 2013 at 09:59:30PM +0800, jianhai luan wrote:
>> [...]
>>>>>>> If use time_after_eq64(), expire ,next_credit and other member
>>>>>>> will must
>>>>>>> be u64.
>>>>>> Yes, you'll need to store next_credit as a u64 in vif instead of
>>>>>> calculating it in tx_credit_exceeded from expires (which is only an
>>>>>> unsigned long).
>>>>> I know that.  Even we use u64, time_after_eq()  will also do wrong
>>>>> judge
>>>>> in theory (not in reality because need long long time).
>>>> If jiffies_64 has millisecond resolution that would be more than
>>>> 500,000,000 years.
>>> Yes, I agree the fact.
>>>>> I think the two better fixed way is below:
>>>>>    - By time_before() to judge if now beyond MAX_ULONG/2
>>>> This is broken, so no.
>>> Where is broken?  would you like to help me point it out.
>> I think David means you didn't actually fix the problem. Your solution is
>> merely a workaround.
> 
> I have think  about using u64, but more code need to be modified and
> that is not all.  Key point is how to change the element of struct
> time_list (expires)  and don't affect other thing?

I already suggested a way that didn't require changing the timer
structure -- calculate and store next_credit in advanced.

David
