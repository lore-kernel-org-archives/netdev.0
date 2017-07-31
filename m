From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: Performance regression with virtio_net
Date: Mon, 31 Jul 2017 09:29:34 -0500
Message-ID: <20170731142934.wcn22fyvjcqyauda@ubuntu-xps13>
References: <20170730222552.4fxxnx3jxg4yv65g@multivac.euank.com>
 <20170731161903-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Euan Kemp <euan.kemp@coreos.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38301 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdGaO3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 10:29:36 -0400
Received: by mail-it0-f46.google.com with SMTP id h199so126163574ith.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 07:29:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170731161903-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 04:26:08PM +0300, Michael S. Tsirkin wrote:
> On Sun, Jul 30, 2017 at 03:25:52PM -0700, Euan Kemp wrote:
> > I've also observed this performance regression.
> > 
> > The minimal fix for me is removing the two
> > > if (unlikely(len > (unsigned long)ctx))
> > checks added in 680557c.
> > 
> > After digging a little more, the reason that check can fail appears to
> > be that add_recvbuf_mergeable sometimes includes a hole at the end,
> > which is included in len but not ctx.
> > 
> > I'd send a patch removing those conditions, but I'm not certain
> > whether "truesize" in receive_mergeable should also be changed back to
> > be the max of len/ctx, or should remain as-is.
> > 
> > - Euan
> 
> Thanks a lot for looking into it!
> 
> I kept this around unchanged from
> ab7db91705e95ed1bba1304388936fccfa58c992.  That commit had an internal
> reason not to account for that space: not enough bits to do it.  No
> longer true so let's account for length exactly.  I'll send a proper
> patch after a bit of testing, would appreciate reports reports of
> whether this helps very much.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

This fixes the issue for me, downloads are faster and rx_length_errors
does not show any errors.

Tested-by: Seth Forshee <seth.forshee@canonical.com>

Thanks!

Seth
