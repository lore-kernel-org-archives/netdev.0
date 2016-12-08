From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v5 0/6] XDP for virtio_net
Date: Thu, 8 Dec 2016 23:16:47 +0200
Message-ID: <20161208231211-mutt-send-email-mst@kernel.org>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161208.141702.1346950420275854265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.fastabend@gmail.com, daniel@iogearbox.net,
        shm@cumulusnetworks.com, tgraf@suug.ch,
        alexei.starovoitov@gmail.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44274 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752652AbcLHVQy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:16:54 -0500
Content-Disposition: inline
In-Reply-To: <20161208.141702.1346950420275854265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 02:17:02PM -0500, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Wed, 07 Dec 2016 12:10:47 -0800
> 
> > This implements virtio_net for the mergeable buffers and big_packet
> > modes. I tested this with vhost_net running on qemu and did not see
> > any issues. For testing num_buf > 1 I added a hack to vhost driver
> > to only but 100 bytes per buffer.
>  ...
> 
> So where are we with this?
> 
> I'm not too thrilled with the idea of making XDP_TX optional or
> something like that.  If someone enables XDP, there is a tradeoff.

The issue is inability of XDP TX to share xmit queues with net stack.
I'm guessing virtio is not the only card that has a limited
number of queues, is it? Is it really so hard to lock the queue
and check it's running? Could be optional in case resources are there
...

-- 
MST
