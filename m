From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC PATCH 0/2] rx zero copy interface for af_packet
Date: Tue, 31 Jan 2017 11:30:42 -0500
Message-ID: <20170131163042.GF8649@oracle.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, brouer@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22092 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbdAaQcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 11:32:23 -0500
Content-Disposition: inline
In-Reply-To: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/27/17 13:33), John Fastabend wrote:
> 
> This is an experimental implementation of rx zero copy for af_packet.
> Its a bit rough and likely has errors but the plan is to clean it up
> over the next few months.
> 
> And seeing I said I would post it in another thread a few days back
> here it is.

One question/comment about this: sure, this saves us an skb copy
on the rx side, but at least for the Tx side, I think there may
be a trade-off between the overhead from the skb setup and the
ease of offloading checksum (and UFO where it is available) to
consider, even for PF_PACKET.

Using PF_PACKET works well for stateless datagram protocols like 
UDP, and for UDP sockets, we find that just switching to Jumbo
(to simulate a poor-man's-UFO) gives us significant improvement
in both throughput and latency for our RDBMS workloads - and 
having the sk_buff facilitates using existing driver-kernel interfaces
for offload easily, so while we may gain some perf improvment by shaving
of the sk_buff overhead, the trade-off needs to be considered.

--Sowmini
