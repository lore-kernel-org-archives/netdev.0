From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [BUG]  TIPC handling of -ERESTARTSYS in connect()
Date: Fri, 31 Aug 2012 09:18:49 -0600
Message-ID: <5040D5D9.4040802@genband.com>
References: <503F84CF.208@genband.com> <504085D9.3010907@windriver.com> <5040D3C4.2010308@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og118.obsmtp.com ([64.18.2.8]:33144 "EHLO
	exprod7og118.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666Ab2HaPTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 11:19:21 -0400
In-Reply-To: <5040D3C4.2010308@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2012 09:09 AM, Chris Friesen wrote:
> On 08/31/2012 03:37 AM, Ying Xue wrote:
>> Hi Chris,
>>
>> Although this is a known issue, still thanks for your report.
>>
>> Regardless of 1.7.7 or mainline, the issue really exists.
>> Can you please check and verify the attached patch?
>>
>> PS: the patch is based on 1.7.7 rather than mainline.
>
>
> I haven't had a chance to test it yet but from visual inspection the
> patch looks pretty good.
>
> It looks like the case where we come in with "sock->state ==
> SS_LISTENING" has changed. Previously we would return -EOPNOTSUPP but
> now it'll be -EINVAL. Is that intentional?

Just noticed something else.  In the SS_CONNECTING case I don't think 
there's any point in setting "res = -EALREADY" since a bit further down 
it gets set unconditionally anyway.

Chris
