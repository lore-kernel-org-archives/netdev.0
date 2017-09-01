From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Fri, 1 Sep 2017 09:12:17 -0700
Message-ID: <1519366e-5418-4dda-db00-5bf50a1c67c4@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170901130311.v5nyx6e6gfats5dg@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com
To: Richard Cochran <richardcochran@gmail.com>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:5921 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751968AbdIAQSh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:18:37 -0400
In-Reply-To: <20170901130311.v5nyx6e6gfats5dg@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,


On 09/01/2017 06:03 AM, Richard Cochran wrote:
> 
> I happy to see this posted.  At first glance, it seems like a step in
> the right direction.
> 
> On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
>>  * Time-aware shaper (802.1Qbv):
> ...
>>    S 0x01 300
>>    S 0x03 500
>>
>>    This means that there are two intervals, the first will have the gate
>>    for traffic class 0 open for 300 nanoseconds, the second will have
>>    both traffic classes open for 500 nanoseconds.
> 
> The i210 doesn't support this in HW, or does it?


No, it does not. i210 only provides support for a per-packet feature called
LaunchTime that can be used control both the fetch and the transmission time of
packets.


> 
>>  * Frame Preemption (802.1Qbu):
>>
>>    To control even further the latency, it may prove useful to signal which
>>    traffic classes are marked as preemptable. For that, 'taprio' provides the
>>    preemption command so you set each traffic class as preemptable or not:
>>
>>    $ tc qdisc (...) \
>>         preemption 0 1 1 1
> 
> Neither can the i210 preempt frames, or what am I missing?

No, it does not.

But when we started working on the shapers we decided to look ahead and try to
come up with interfaces that could cover beyond 802.1Qav. These are just some
ideas we've been prototyping here together with the 'cbs' qdisc.


> 
> The timing of this RFC is good, as I am just finishing up an RFC that
> implements time-based transmit using the i210.  I'll try and get that
> out ASAP.


Is it correct to assume you are referring to an interface for Launchtime here?


Thanks,
Jesus
