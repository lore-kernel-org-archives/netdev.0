From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 0/4] Configuring traffic classes via
 new hardware offload mechanism in tc/mqprio
Date: Fri, 19 May 2017 15:30:57 -0700
Message-ID: <591F7221.3050303@gmail.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36367 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbdESWbJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:31:09 -0400
Received: by mail-pf0-f179.google.com with SMTP id m17so45695105pfg.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 15:31:08 -0700 (PDT)
In-Reply-To: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 05:58 PM, Amritha Nambiar wrote:
> The following series introduces a new harware offload mode in
> tc/mqprio where the TCs, the queue configurations and bandwidth rate
> limits are offloaded to the hardware. The i40e driver enables the new
> mqprio hardware offload mechanism factoring the TCs, queue
> configuration and bandwidth rates by creating HW channel VSIs.
> 

nice work, fix your time stamp and line wrapping though.


> In this mode, the priority to traffic class mapping and the user
> specified queue ranges are used to configure the traffic class when
> the 'hw' option is set to 2. This is achieved by creating HW
> channels(VSI). A new channel is created for each of the traffic class
> configuration offloaded via mqprio framework except for the first TC
> (TC0) which is for the main VSI. TC0 for the main VSI is also
> reconfigured as per user provided queue parameters. Finally,
> bandwidth rate limits are set on these traffic classes through the
> mqprio offload framework by sending these rates in addition to the
> number of TCs and the queue configurations.
> Example:
> # tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
>   queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2
> 
> To dump the bandwidth rates:
> 
> # tc qdisc show dev eth0
>   qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>                queues:(0:3) (4:7)
>                min rates:0bit 0bit
>                max rates:55Mbit 60Mbit
> 

Looks reasonable to me thanks. Previously, rate limits were being set
via dcbnl but I guess this interface is slightly nicer in that it puts
all configuration in one spot. IMO it would be nice to push dcbnl users
over to this.

Thanks,
.John
