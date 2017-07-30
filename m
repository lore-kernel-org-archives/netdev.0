From: Euan Kemp <euan.kemp@coreos.com>
Subject: Re: Performance regression with virtio_net
Date: Sun, 30 Jul 2017 15:25:52 -0700
Message-ID: <20170730222552.4fxxnx3jxg4yv65g@multivac.euank.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: mst@redhat.com, seth.forshee@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:37462 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdG3WZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 18:25:54 -0400
Received: by mail-pg0-f45.google.com with SMTP id y129so130709473pgy.4
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 15:25:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've also observed this performance regression.

The minimal fix for me is removing the two
> if (unlikely(len > (unsigned long)ctx))
checks added in 680557c.

After digging a little more, the reason that check can fail appears to
be that add_recvbuf_mergeable sometimes includes a hole at the end,
which is included in len but not ctx.

I'd send a patch removing those conditions, but I'm not certain
whether "truesize" in receive_mergeable should also be changed back to
be the max of len/ctx, or should remain as-is.

- Euan
