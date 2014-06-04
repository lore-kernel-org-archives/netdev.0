From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Subject: Re: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 4 Jun 2014 23:16:40 +0530
Message-ID: <CAJMXqXY-1_OiOh+BttA-E97M05QWW8S7KyWP3p9ZJK_FzgtroA@mail.gmail.com>
References: <CAJMXqXbfEj1pq0nfLCeJuqWOeW1xfGwCmeKm_u4ZKdLepzwKiA@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D17257279@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:61452 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaFDRql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 13:46:41 -0400
Received: by mail-vc0-f182.google.com with SMTP id id10so9253025vcb.27
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 10:46:40 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17257279@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Jun 4, 2014 at 7:42 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Suprasad Mutalik Desai
>>     Currently i am working on 3.10.12 kernel and it seems the Linux
>> stack performance (TCP and UDP) has degraded drastically as compared
>> to 2.6 kernel.
>>
>> Results :
>>
>> Linux 2.6.32
>> ---------------------
>> TCP traffic using iperf
>>     - Upstream : 140 Mbps
>>     - Downstream : 148 Mbps
>>
>> UDP traffic using iperf
>>     - Upstream : 200 Mbps
>>     - Downstream : 245 Mbps
>>
>> Linux 3.10.12
>> --------------------
>> TCP traffic using iperf
>>     - Upstream : 101 Mbps
>>     - Downstream : 106 Mbps
>>
>> UDP traffic using iperf
>>     - Upstream : 140 Mbps
>>     - Downstream : 170 Mbps
>>
>> Analysis:
>> ---------------
>> 1.   As per profiling data on Linux-3.10.12 it seems,
>>              -   fib_table_lookup and ip_route_input_noref is being
>> called most of the times and thus causing the degradation in
>> performance.
>>
>>     8.77    csum_partial 0x80009A20 1404
>>     4.53    ipt_do_table 0x80365C34 1352
>>     3.45    eth_xmit 0x870D0C88 5460
>>     3.41    fib_table_lookup 0x8035240C 856    <----------
>>     3.38    __netif_receive_skb_core 0x802B5C00 2276
>>     3.07    dma_device_write 0x80013BD4 752
>>     2.94    nf_iterate 0x802EA380 256
>>     2.69    ip_route_input_noref 0x8030CE14 2520    <--------------
>>     2.24    ip_forward 0x8031108C 1040
>>     2.04    tcp_packet 0x802F45BC 3956
>>     1.93    nf_conntrack_in 0x802EEAF4 2284
>>
>> 2.    Based on the above observation, when searched,  it seems Routing
>> cache code has been removed from Linux-3.6 kernel and thus every
>> packet has to go       through ip_route_input_noref to find the
>> destination.
>
> That doesn't look like enough cpu time to give the observed reduction
> in throughput (assuming those numbers are in %).
>

Yes, you are correct.We are running the test for a short duration .
Currently we run iperf for 50 iterations .

I cross checked by running more iterations but the behaviour is same
as we observe performance degradation .


> Are you sure the system is actually running at 100% cpu?
> (Although I'm not sure what to trust for cpu usage with these sorts of tests.)
>
>         David

Yes, we checked with mpstat and cpu loading was 100%.

Regards,
Suprasad
