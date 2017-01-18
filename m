From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 0/6] virtio_net XDP fixes and adjust_header support
Date: Wed, 18 Jan 2017 17:48:37 +0200
Message-ID: <20170118174700-mutt-send-email-mst@kernel.org>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751992AbdARPsj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 10:48:39 -0500
Content-Disposition: inline
In-Reply-To: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 02:19:27PM -0800, John Fastabend wrote:
> This has a fix to handle small buffer free logic correctly and then
> also adds adjust head support.
> 
> I pushed adjust head at net (even though its rc3) to avoid having
> to push another exception case into virtio_net to catch if the
> program uses adjust_head and then block it. If there are any strong
> objections to this we can push it at net-next and use a patch from
> Jakub to add the exception handling but then user space has to deal
> with it either via try/fail logic or via kernel version checks. Granted
> we already have some cases that need to be configured to enable XDP
> but I don't see any reason to have yet another one when we can fix it
> now vs delaying a kernel version.

1, 3 and 4 definitely look good to me.
I don't like the big hammer approach that other patches
take though. Sent some comments, and I'd like to ponder it for a
couple of days.



> 
> v2: fix spelling error, convert unsigned -> unsigned int
> v3: v2 git crashed during send so retrying sorry for the noise
> v4: changed layout of rtnl_lock fixes (Stephen)
>     moved reset logic into virtio core with new patch (MST)
>     fixed up linearize and some code cleanup (Jason)
> 
>     Otherwise did some generic code cleanup so might be a bit
>     cleaner this time at least that is the hope.
> v5: fixed rtnl_lock issue (DaveM)
> 
>     In order to fix rtnl_lock issue and also to address Jason's
>     comment questioning the need for a generic virtio_device_reset
>     routine I exported some virtio core routines and then wrote
>     virtio_net reset routine. This is the cleanest solution I
>     came up with today and I do not at this time have any need
>     for a more generic reset. If folks don't like this I could
>     revert back to v3 variant but Stephen pointed out that the
>     pattern used there is also not ideal.
> 
> Thanks for the review.
> 
> ---
> 
> John Fastabend (6):
>       virtio_net: use dev_kfree_skb for small buffer XDP receive
>       virtio_net: wrap rtnl_lock in test for calling with lock already held
>       virtio_net: factor out xdp handler for readability
>       virtio_net: remove duplicate queue pair binding in XDP
>       virtio_net: refactor freeze/restore logic into virtnet reset logic
>       virtio_net: XDP support for adjust_head
> 
> 
>  drivers/net/virtio_net.c |  332 ++++++++++++++++++++++++++++++----------------
>  drivers/virtio/virtio.c  |   42 +++---
>  include/linux/virtio.h   |    4 +
>  3 files changed, 247 insertions(+), 131 deletions(-)
> 
> --
> Signature
