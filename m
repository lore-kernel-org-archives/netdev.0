From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 0/2] rx zero copy interface for af_packet
Date: Tue, 31 Jan 2017 20:23:51 -0800
Message-ID: <589162D7.60108@gmail.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <20170131163042.GF8649@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bjorn.topel@gmail.com, jasowang@redhat.com, ast@fb.com,
        alexander.duyck@gmail.com, brouer@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34388 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdBAEYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 23:24:09 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so30819959pfb.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 20:24:09 -0800 (PST)
In-Reply-To: <20170131163042.GF8649@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-31 08:30 AM, Sowmini Varadhan wrote:
> On (01/27/17 13:33), John Fastabend wrote:
>>
>> This is an experimental implementation of rx zero copy for af_packet.
>> Its a bit rough and likely has errors but the plan is to clean it up
>> over the next few months.
>>
>> And seeing I said I would post it in another thread a few days back
>> here it is.
> 
> One question/comment about this: sure, this saves us an skb copy
> on the rx side, but at least for the Tx side, I think there may
> be a trade-off between the overhead from the skb setup and the
> ease of offloading checksum (and UFO where it is available) to
> consider, even for PF_PACKET.
> 

Yes although as Willem suggested and I pushed a quick comment
at the end of the patch, virtio descriptors might be a better
options for a v4 descriptor type because they have mechanisms
to handle checksum and others in place already.

> Using PF_PACKET works well for stateless datagram protocols like 
> UDP, and for UDP sockets, we find that just switching to Jumbo
> (to simulate a poor-man's-UFO) gives us significant improvement
> in both throughput and latency for our RDBMS workloads - and 
> having the sk_buff facilitates using existing driver-kernel interfaces
> for offload easily, so while we may gain some perf improvment by shaving
> of the sk_buff overhead, the trade-off needs to be considered.

Of course but many workloads/environments can not use jumbo
frames nor would it be helpful if your average pkt size is
128B or something around there.


> 
> --Sowmini
> 
> 
> 
