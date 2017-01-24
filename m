From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small
 buffer XDP receive
Date: Tue, 24 Jan 2017 15:11:39 -0500 (EST)
Message-ID: <20170124.151139.1496962673545808215.davem@davemloft.net>
References: <20170123230809-mutt-send-email-mst@kernel.org>
        <20170124.144328.2195698124358175034.davem@davemloft.net>
        <20170124215412-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, jasowang@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdAXUMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:12:05 -0500
In-Reply-To: <20170124215412-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 24 Jan 2017 22:08:33 +0200

> On Tue, Jan 24, 2017 at 02:43:28PM -0500, David Miller wrote:
>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> Date: Mon, 23 Jan 2017 23:08:35 +0200
>> 
>> > On Tue, Jan 17, 2017 at 02:19:50PM -0800, John Fastabend wrote:
>> >> In the small buffer case during driver unload we currently use
>> >> put_page instead of dev_kfree_skb. Resolve this by adding a check
>> >> for virtnet mode when checking XDP queue type. Also name the
>> >> function so that the code reads correctly to match the additional
>> >> check.
>> >> 
>> >> Fixes: bb91accf2733 ("virtio-net: XDP support for small buffers")
>> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> >> Acked-by: Jason Wang <jasowang@redhat.com>
>> > 
>> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
>> > 
>> > I think we definitely want this one in -net as it's
>> > a bugfix.
>> 
>> This whole series is a bug fix, we must have adjust_header XDP
>> support in the virtio_net driver before v4.10 goes out, it is
>> a requires base feature for XDP.
> 
> I have to say device resets outside probe have a huge potential
> to uncover hypervisor bugs. I am rather uncomfortable
> doing that after -rc1.
> 
> How about a module option to disable it by default?
> We can then ship a partial implementation in 4.10
> and work on completing it in 4.11.

XDP programmers must be able to assume a base set of features being
present, adjust_header is one of them.
