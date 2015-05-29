From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Thu, 28 May 2015 22:31:05 -0700
Message-ID: <5567F999.5080704@cumulusnetworks.com>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com> <20150518.161916.2132217836491222672.davem@davemloft.net> <20150528094244.GA19629@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	john.fastabend@gmail.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35864 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbbE2FbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 01:31:07 -0400
Received: by pacux9 with SMTP id ux9so1669563pac.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 22:31:07 -0700 (PDT)
In-Reply-To: <20150528094244.GA19629@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/28/15, 2:42 AM, Jiri Pirko wrote:
> Mon, May 18, 2015 at 10:19:16PM CEST, davem@davemloft.net wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Date: Sun, 17 May 2015 16:42:05 -0700
>>
>>> On most systems where you can offload routes to hardware,
>>> doing routing in software is not an option (the cpu limitations
>>> make routing impossible in software).
>> You absolutely do not get to determine this policy, none of us
>> do.
>>
>> What matters is that by default the damn switch device being there
>> is %100 transparent to the user.
>>
>> And the way to achieve that default is to do software routes as
>> a fallback.
>>
>> I am not going to entertain changes of this nature which fail
>> route loading by default just because we've exceeded a device's
>> HW capacity to offload.
>>
>> I thought I was _really_ clear about this at netdev 0.1
> I certainly agree that by default, transparency 1:1 sw:hw mapping is
> what we need for fib. The current code is a good start!
>
> I see couple of issues regarding switchdev_fib_ipv4_abort:
> 1) If user adds and entry, switchdev_fib_ipv4_add fails, abort is
>     executed -> and, error returned. I would expect that route entry should
>     be added in this case. The next attempt of adding the same entry will
>     be successful.
>     The current behaviour breaks the transparency you are reffering to.
> 2) When switchdev_fib_ipv4_abort happens to be executed, the offload is
>     disabled for good (until reboot). That is certainly not nice, alhough
>     I understand that is the easiest solution for now.

+1
>
> I believe that we all agree that the 1:1 transparency, although it is a
> default, may not be optimal for real-life usage. HW resources are
> limited and user does not know them. The danger of hitting _abort and
> screwing-up the whole system is huge, unacceptable.
>
> So here, there are couple of more or less simple things that I suggest to
> do in order to move a little bit forward:
> 1) Introduce system-wide option to switch _abort to just plain fail.
>     When HW does not have capacity, do not flush and fallback to sw, but
>     rather just fail to add the entry. This would not break anything.
>     Userspace has to be prepared that entry add could fail.
This was my option b)
> 2) Introduce a way to propagate resources to userspace. Driver knows about
>     resources used/available/potentially_available. Switchdev infra could
>     be extended in order to propagate the info to the user.
This could be an option as well. On our switches we do provide a utility 
to query
similar hardware resources/stats. We were planning to propose a netlink
based query/get api for the switchdev case.
> 3) Introduce couple of flags for entry add that would alter the default
>     behaviour. Something like:
>     	NLM_F_SKIP_KERNEL
>     	NLM_F_SKIP_OFFLOAD
+1, we have discussed similar flags in many other switchdev discussions 
as well.
and this is also along the lines of option c) that i was proposing as 
possible alternatives with this patch.
>     Again, this does not break the current users. On the other hand, this
>     gives new users a leverage to instruct kernel where the entry should
>     be added to (or not added to).
>
> Any thoughts? Objections?
>
>
+1 to all what you said.

thanks
