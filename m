From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V6 net-next 0/5] xen-net{back,front}: Multiple transmit
 and receive queues
Date: Fri, 14 Mar 2014 16:10:36 +0000
Message-ID: <1394813436.6442.138.camel@kazak.uk.xensource.com>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50183 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754113AbaCNQKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 12:10:39 -0400
In-Reply-To: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-03 at 11:47 +0000, Andrew J. Bennieston wrote:
> This patch series implements multiple transmit and receive queues (i.e.
> multiple shared rings) for the xen virtual network interfaces.
> 
> The series is split up as follows:
>  - Patches 1 and 3 factor out the queue-specific data for netback and
>     netfront respectively, and modify the rest of the code to use these
>     as appropriate.
>  - Patches 2 and 4 introduce new XenStore keys to negotiate and use
>    multiple shared rings and event channels, and code to connect these
>    as appropriate.
>  - Patch 5 documents the XenStore keys required for the new feature
>    in include/xen/interface/io/netif.h
> 
> All other transmit and receive processing remains unchanged, i.e. there
> is a kthread per queue and a NAPI context per queue.
> 
> The performance of these patches has been analysed in detail, with
> results available at:
> 
> http://wiki.xenproject.org/wiki/Xen-netback_and_xen-netfront_multi-queue_performance_testing
> 
> To summarise:
>   * Using multiple queues allows a VM to transmit at line rate on a 10
>     Gbit/s NIC, compared with a maximum aggregate throughput of 6 Gbit/s
>     with a single queue.
>   * For intra-host VM--VM traffic, eight queues provide 171% of the
>     throughput of a single queue; almost 12 Gbit/s instead of 6 Gbit/s.

>From the graphs it looks like 8 queues doesn't offer that much over 4
and the bulk of the improvement comes from going to just 2 queues.

Any idea what the bottleneck is? i.e. why does the graph flatten so
soon?

>   * There is a corresponding increase in total CPU usage, i.e. this is a
>     scaling out over available resources, not an efficiency improvement.

corresponding to the number of queues or the throughput improvement?
i.e. is it 8x or 1.71x with 8 queues?

Ian.
