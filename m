From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v4 5/5] perf:add a script shows a process of packet
Date: Tue, 7 Sep 2010 18:57:25 +0200
Message-ID: <20100907165721.GA5495@nowhere>
References: <4C72422C.5070102@jp.fujitsu.com> <4C72439D.3040001@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	nhorman@tuxdriver.com, laijs@cn.fujitsu.com,
	scott.a.mcmillan@intel.com, rostedt@goodmis.org,
	eric.dumazet@gmail.com, mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39256 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757967Ab0IGQ5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 12:57:19 -0400
Content-Disposition: inline
In-Reply-To: <4C72439D.3040001@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 06:47:09PM +0900, Koki Sanagi wrote:
> Add a perf script which shows a process of packets and processed time.
> It helps us to investigate networking or network device.
> 
> If you want to use it, install perf and record perf.data like following.
> 
> #perf trace record netdev-times [script]
> 
> If you set script, perf gathers records until it ends.
> If not, you must Ctrl-C to stop recording.
> 
> And if you want a report from record,
> 
> #perf trace report netdev-times [options]
> 
> If you use some options, you can limit an output.
> Option is below.
> 
> tx: show only process of tx packets
> rx: show only process of rx packets
> dev=: show a process specified with this option
> debug: work with debug mode. It shows buffer status.
> 
> For example, if you want to show a process of received packets associated
> with eth4,
> 
> #perf trace report netdev-times rx dev=eth4
> 106133.171439sec cpu=0
>   irq_entry(+0.000msec irq=24:eth4)
>          |
>   softirq_entry(+0.006msec)
>          |
>          |---netif_receive_skb(+0.010msec skb=f2d15900 len=100)
>          |            |
>          |      skb_copy_datagram_iovec(+0.039msec 10291::10291)
>          |
>   napi_poll_exit(+0.022msec eth4)
> 
> This perf script helps us to analyze a process time of transmit/receive
> sequence.
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  tools/perf/scripts/python/bin/netdev-times-record |    8 +
>  tools/perf/scripts/python/bin/netdev-times-report |    5 +
>  tools/perf/scripts/python/netdev-times.py         |  464 +++++++++++++++++++++
>  3 files changed, 477 insertions(+), 0 deletions(-)
> 
> diff --git a/tools/perf/scripts/python/bin/netdev-times-record b/tools/perf/scripts/python/bin/netdev-times-record
> new file mode 100644
> index 0000000..2b59511
> --- /dev/null
> +++ b/tools/perf/scripts/python/bin/netdev-times-record
> @@ -0,0 +1,8 @@
> +#!/bin/bash
> +perf record -c 1 -f -R -a -e net:net_dev_xmit -e net:net_dev_queue	\


Nano-nits:

-c 1 and -R are now default settings for tracepoints and -f is not
needed anymore. I've removed them.



> +all_event_list = []; # insert all tracepoint event related with this script



Ah I didn't know ";" works with python :)


> +def trace_end():
> +	# order all events in time
> +	all_event_list.sort(lambda a,b :cmp(a[EINFO_IDX_TIME],
> +					    b[EINFO_IDX_TIME]))



Events already arrive in time order to the scripts.

Thnaks!

