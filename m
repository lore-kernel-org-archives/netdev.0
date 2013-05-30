From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Thu, 30 May 2013 16:57:38 -0400
Message-ID: <51A7BD42.8060504@redhat.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com> <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com> <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com> <20130525151347.GB25744@lintop.rgmadvisors.com> <20130528201508.GA6409@sbohrermbp13-local.rgmadvisors.com> <CAJZOPZLZmLi3V-3D_16FZHQLsCsHKZY7ZhvaEH1k=Pw_i+ciwQ@mail.gmail.com> <20130530203113.GA4891@sbohrermbp13-local.rgmadvisors.com> <CAJZOPZ+YSWhz0Hw+BWHeT=cEDqRj-s7uY4M-5CTiXcRgJND_+Q@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811Ab3E3U5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 16:57:47 -0400
In-Reply-To: <CAJZOPZ+YSWhz0Hw+BWHeT=cEDqRj-s7uY4M-5CTiXcRgJND_+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2013 04:42 PM, Or Gerlitz wrote:
> On Thu, May 30, 2013 at 11:31 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
>>> So we need to
>>> debug/bisect why without the patch (what you call high_rate_steer=0)
>>> you don't get data on all groups. Can you bisect that on a single
>>> node, e.g set the rest of the environment with 3.4 that works, and on
>>> a given node see what is the commit that breaks that?
>
>> Done. It appears that the patch that breaks receiving packets on many
>> different multicast groups/sockets is:
>>
>> commit 4cd729b04285b7330edaf5a7080aa795d6d15ff3
>> Author: Vlad Yasevich <vyasevic@redhat.com>
>> Date:   Mon Apr 15 09:54:25 2013 +0000
>>
>>      net: add dev_uc_sync_multiple() and dev_mc_sync_multiple() api
>>
>>      The current implementation of dev_uc_sync/unsync() assumes that there is
>>      a strict 1-to-1 relationship between the source and destination of the sync.
>>      In other words, once an address has been synced to a destination device, it
>>      will not be synced to any other device through the sync API.
>>      However, there are some virtual devices that aggreate a number of lower
>>      devices and need to sync addresses to all of them.  The current
>>      API falls short there.
>>
>>      This patch introduces a new dev_uc_sync_multiple() api that can be called
>>      in the above circumstances and allows sync to work for every invocation.
>>
>>      CC: Jiri Pirko <jiri@resnulli.us>
>>      Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>      Signed-off-by: David S. Miller <davem@davemloft.net>
>>
>> I've confirmed that reverting this patch on top of 3.10-rc3 allows me
>> to receive packets on all of my multicast groups without the Mellanox
>> high_rate_steer option set.
>
> OK, impressive debugging... so what do we do from here? Vlad, Shawn
> observes a regression once this patch is used on a large scale setup
> that uses many multicast groups (you can read the posts done earlier
> on this thread), does this rings any bell w.r.t to the actual problem
> in the patch?

I haven't seen that, but I didn't test with that many multicast groups. 
  I had 20 groups working.

I'll take a look and see what might be going on.

Thanks
-vlad

>
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
