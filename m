From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/6] Configuring traffic classes via new hardware offload
 mechanism in tc/mqprio
Date: Fri, 14 Jul 2017 03:56:08 -0400
Message-ID: <13371d93-6362-b56f-3655-a85b37f5667e@mojatatu.com>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        netdev@vger.kernel.org, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        sridhar.samudrala@intel.com, carolyn.wyborny@intel.com,
        Roman Mashak <mrv@mojatatu.com>
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35344 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdGNH4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 03:56:11 -0400
Received: by mail-wr0-f193.google.com with SMTP id y28so6543362wrd.2
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 00:56:11 -0700 (PDT)
In-Reply-To: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amritha,

On 17-07-11 06:18 AM, Amritha Nambiar wrote:
> The following series introduces a new hardware offload mode in
> tc/mqprio where the TCs, the queue configurations and
> bandwidth rate limits are offloaded to the hardware. The existing
> mqprio framework is extended to configure the queue counts and
> layout and also added support for rate limiting. This is achieved
> by setting the value 2 for the "hw" mode. Legacy devices can fall
> back to the existing setup supporting hw mode 1 where only the
> TCs are offloaded, however if hw mode 2 is specified, then this
> type of offload fails to initialize if the requested mode is not
> supported. The i40e driver enables the new mqprio hardware offload
> mechanism factoring the TCs, queue configuration and bandwidth
> rates by creating HW channel VSIs.
> 
> In this new mode, the priority to traffic class mapping and the
> user specified queue ranges are used to configure the traffic
> class when the 'hw' option is set to 2. This is achieved by
> creating HW channels(VSI). A new channel is created for each
> of the traffic class configuration offloaded via mqprio
> framework except for the first TC (TC0) which is for the main
> VSI. TC0 for the main VSI is also reconfigured as per user
> provided queue parameters. Finally, bandwidth rate limits are
> set on these traffic classes through the mqprio offload
> framework by sending these rates in addition to the number of
> TCs and the queue configurations.
> 
> Example:
> # tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
>    queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2
> 
> To dump the bandwidth rates:
> 
> # tc qdisc show dev eth0
>    qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>                 queues:(0:3) (4:7)
>                 min rates:0bit 0bit
>                 max rates:55Mbit 60Mbit

My only concern is usability. Was already cryptic with hw "1" and
now we introduce another magic number "2". Could we not have two
have some human friendly nouns? I know 1 means offload qos and two
mean offload rate (+qos?).

I have some questions:
BTW, what would tc class show dev eth0 display in this case?
Above seems to select queue groupings for a specific rates which
is a short-cut to say assigning each queue via something like TBF
via "tc class" semantics (but way more cryptic than tc class;->)

cheers,
jamal
