From: Myungho Jung <mhjungk@gmail.com>
Subject: Re: [PATCH v2] net: core: Prevent from dereferencing null pointer
 when
Date: Mon, 24 Apr 2017 19:39:12 -0700
Message-ID: <20170425023912.GA12364@fqdn.specialj.com>
References: <1492732760-25081-1-git-send-email-mhjungk@gmail.com>
 <20170424.120235.438297438450788048.davem@davemloft.net>
 <20170425010052.GA8717@fqdn.specialj.com>
 <20170424.214450.2215530406378773476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33728 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940018AbdDYCjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 22:39:15 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so51980155ioi.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 19:39:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170424.214450.2215530406378773476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 09:44:50PM -0400, David Miller wrote:
> From: Myungho Jung <mhjungk@gmail.com>
> Date: Mon, 24 Apr 2017 18:00:52 -0700
> 
> > On Mon, Apr 24, 2017 at 12:02:35PM -0400, David Miller wrote:
> >> From: Myungho Jung <mhjungk@gmail.com>
> >> Date: Thu, 20 Apr 2017 16:59:20 -0700
> >> 
> >> > Added NULL check to make __dev_kfree_skb_irq consistent with kfree
> >> > family of functions.
> >> > 
> >> > Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289
> >> > 
> >> > Signed-off-by: Myungho Jung <mhjungk@gmail.com>
> >> > ---
> >> > Changes in v2:
> >> >  - Correct category in subject
> >> 
> >> This subject line is an incomplete sentence.
> >> 
> >> This patch prevents dereferenccing a null pointer when "what"?
> > 
> > As it was reported on bugzilla, it would happen when plugging p54 usb device
> > to RPi2. But, i'm not 100% sure that this patch will resolve the issue because
> > the reporter didn't try my patch yet and I don't have the device to test.
> > 
> > And there might be some other places calling the function without checking
> > null pointer. The thing is that only the function don't check null among
> > kfree functions. So, I just hope this patch will prevent potential oops
> > issues.
> 
> It doesn't check for a NULL pointer because it is almost exclusively
> used in the interrupt paths where we know we have a non-NULL skb.

Yes, actually null is checked before calling the function in most
cases. That's why my first patch was applied not to net/core but to
p54 driver because I was worried about duplicated checking.

But, Christian suggested this patch to make it consistent with other
kfree functions and consume_skb, and Eric agreed with that.

Thanks,
Myungho
