From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Wed, 18 Oct 2017 15:37:35 -0700
Message-ID: <62f3eae4-bf6a-1475-936f-5011c9ff381e@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost> <87k20vip3f.fsf@intel.com>
 <20170919052244.77umdxuze53t6j22@localhost> <87wp4ufchl.fsf@intel.com>
 <20170920052558.h6c4lkqmzk2h2pdq@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, Levi Pearson <levipearson@gmail.com>,
        Henrik Austad <henrik@austad.us>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:43359 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750975AbdJRWpC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 18:45:02 -0400
In-Reply-To: <20170920052558.h6c4lkqmzk2h2pdq@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,


On 09/19/2017 10:25 PM, Richard Cochran wrote:
(...)
>  
>> I have a question, what about a controller that doesn't provide a way to
>> set a per-packet transmission time, but it supports Qbv/Qbu. What would
>> be your proposal to configure it?
> 
> SO_TXTIME will have a generic SW fallback.
> 
> BTW, regarding the i210, there is no sensible way to configure both
> CBS and time based transmission at the same time.  The card performs a
> logical AND to make the launch decision.  The effect of this is that
> each and every packet needs a LaunchTime, and the driver would be
> forced to guess the time for a packet before entering it into its
> queue.
> 
> So if we end up merging CBS and SO_TXTIME, then we'll have to make
> them exclusive of each other (in the case of the i210) and manage the
> i210 queue configurations correctly.
> 

I've ran some quick tests here having launch time enabled on i210 + our cbs
patchset. When valid Launch times are set on each packet you still get the
expected behavior, so I'm not sure we should just make them exclusive of each other.

I also did some tests with when you don't set valid launch times, but here using
your idea from above, so with the driver calculating a valid launch time (i.e.
current NIC time + X ns, varying X across tests) for packets that didn't have it
set by the user, and I wasn't too happy with its reliability. It could
definitely be improved, but it has left me wondering: instead, what about
documenting that if you enable TXTIME, then you *must* provide a valid Launch
time for all packets on traffic classes that are affected?

With the SO_TXTIME qdisc idea in place, that could even be enforced before
packets were enqueued into the netdevice.


Regards,
Jesus
