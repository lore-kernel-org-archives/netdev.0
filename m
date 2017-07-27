From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: Performance regression with virtio_net
Date: Thu, 27 Jul 2017 16:14:30 -0500
Message-ID: <20170727211430.viki2jcxbzk2u62c@ubuntu-hedt>
References: <20170727170942.ub24lwgrl3x2outp@ubuntu-hedt>
 <20170727233244-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:38785 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdG0VOc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 17:14:32 -0400
Received: by mail-it0-f42.google.com with SMTP id h199so88748986ith.1
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 14:14:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170727233244-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 11:38:52PM +0300, Michael S. Tsirkin wrote:
> On Thu, Jul 27, 2017 at 12:09:42PM -0500, Seth Forshee wrote:
> > I'm seeing a performance regression with virtio_net that looks to have
> > started in 4.12-rc1. I only see it in one context though, downloading
> > snap packages from the Ubuntu snap store. For example:
> > 
> >  https://api.snapcraft.io/api/v1/snaps/download/b8X2psL1ryVrPt5WEmpYiqfr5emixTd7_1797.snap
> > 
> > which redirects to Internap's CDN. Normally this downloads in a few
> > seconds at ~10 MB/s, but with 4.12 and 4.13 it takes minutes with a rate
> > of ~150 KB/s. Everything else I've tried downloads as normal speeds.
> 
> So just wget that URL should be enough?

Yes. Note that sometimes it starts out faster then slows down.

> > I bisected this to 680557cf79f8 "virtio_net: rework mergeable buffer
> > handling". If I revert this on top of 4.13-rc2 (along with other changes
> > needed to successfully revert it) speeds return to normal.
> > 
> > Thanks,
> > Seth
> 
> 
> Interesting. A more likely suspect would be
> e377fcc8486d40867c6c217077ad0fa40977e060 - could you please try
> reverting that one instead?

I tried it, and I still get slow download speeds. I did test at
680557cf79f82623e2c4fd42733077d60a843513 during the bisect so I'm
reasonably confident that this is the one where things went bad.

> Also, could you please look at mergeable_rx_buffer_size in sysfs with
> and without the change?

In all cases (stock 4.13-rc2, 680557cf79f8 reverted, and e377fcc8486d
reverted) mergeable_rx_buffer_size was 1536.

Thanks,
Seth
