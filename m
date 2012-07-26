From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Wed, 25 Jul 2012 19:30:13 -0700
Message-ID: <CAKgT0UeNunHysvJvXcPN38B=mAD5FbSiKigsuS7AYC5TEH6BQg@mail.gmail.com>
References: <CAKgT0UdcqE52WFCT-t2om0SN3Yq5GqiwN+JbwCcnBv4LDOB6BQ@mail.gmail.com>
	<20120725.161732.91008692477078715.davem@davemloft.net>
	<20120725.163939.581743307449189972.davem@davemloft.net>
	<20120725.175406.1331203183232530233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:33759 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab2GZCaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 22:30:14 -0400
Received: by vcbfk26 with SMTP id fk26so1237141vcb.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 19:30:13 -0700 (PDT)
In-Reply-To: <20120725.175406.1331203183232530233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 25, 2012 at 5:54 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 25 Jul 2012 16:39:39 -0700 (PDT)
>
>> From: David Miller <davem@davemloft.net>
>> Date: Wed, 25 Jul 2012 16:17:32 -0700 (PDT)
>>
>>> From: Alexander Duyck <alexander.duyck@gmail.com>
>>> Date: Wed, 25 Jul 2012 16:02:45 -0700
>>>
>>>> Since your patches are in I have started to re-run my tests. I am
>>>> seeing a significant drop in throughput with 8 flows which I expected,
>>>> however it looks like one of the biggest issues I am seeing is that
>>>> the dst_hold and dst_release calls seem to be causing some serious
>>>> cache thrash.  I was at 12.5Mpps w/ 8 flows before the patches, after
>>>> your patches it drops to 8.3Mpps.
>>>
>>> Yes, this is something we knew would start happening.
>>>
>>> One idea is to make cached dsts be per-cpu in the nexthops.
>>
>> Actually I think what really kills your case is the removal of the
>> noref path for route lookups.  I'll work on a patch to restore that
>> in the case where we use cached routes from the FIB nexthops.
>
> Alex, here is something I tossed together, does it help with the
> dst_hold()/dst_release() overhead at all?
>

I downloaded your patch, applied it, rebuilt the kernel, and then
rebooted.  However after the reboot I am unable to access the system
remotely.  It looks like I will have to wait until I get into the
office tomorrow to figure out what happened to the system.

I will get you an update on if it helped or not once I figure out what
happened in the morning.

Thanks,

Alex
