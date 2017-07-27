From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Performance regression with virtio_net
Date: Thu, 27 Jul 2017 23:38:52 +0300
Message-ID: <20170727233244-mutt-send-email-mst@kernel.org>
References: <20170727170942.ub24lwgrl3x2outp@ubuntu-hedt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Seth Forshee <seth.forshee@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50358 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751554AbdG0Uix (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jul 2017 16:38:53 -0400
Content-Disposition: inline
In-Reply-To: <20170727170942.ub24lwgrl3x2outp@ubuntu-hedt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 12:09:42PM -0500, Seth Forshee wrote:
> I'm seeing a performance regression with virtio_net that looks to have
> started in 4.12-rc1. I only see it in one context though, downloading
> snap packages from the Ubuntu snap store. For example:
> 
>  https://api.snapcraft.io/api/v1/snaps/download/b8X2psL1ryVrPt5WEmpYiqfr5emixTd7_1797.snap
> 
> which redirects to Internap's CDN. Normally this downloads in a few
> seconds at ~10 MB/s, but with 4.12 and 4.13 it takes minutes with a rate
> of ~150 KB/s. Everything else I've tried downloads as normal speeds.

So just wget that URL should be enough?

> I bisected this to 680557cf79f8 "virtio_net: rework mergeable buffer
> handling". If I revert this on top of 4.13-rc2 (along with other changes
> needed to successfully revert it) speeds return to normal.
> 
> Thanks,
> Seth


Interesting. A more likely suspect would be
e377fcc8486d40867c6c217077ad0fa40977e060 - could you please try
reverting that one instead?
Also, could you please look at mergeable_rx_buffer_size in sysfs with
and without the change?

-- 
MST
