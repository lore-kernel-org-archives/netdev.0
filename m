From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/4] virtio_net: don't free buffers in xmit ring
Date: Tue, 2 Jun 2009 23:37:33 +0930
Message-ID: <200906022337.33799.rusty@rustcorp.com.au>
References: <200905292346.24141.rusty@rustcorp.com.au> <1243930422.9146.60.camel@blaa> <1243942902.9146.216.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49882 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333AbZFBOLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 10:11:36 -0400
In-Reply-To: <1243942902.9146.216.camel@blaa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Jun 2009 09:11:42 pm Mark McLoughlin wrote:
> On Tue, 2009-06-02 at 09:13 +0100, Mark McLoughlin wrote:
> > I think skb_orphan() is enough to prevent this, is it?
>
> Oops, I meant:
>
>   I don't think skb_orphan() is enough to prevent this, is it?

Yes, point taken.  No, it's not.  We could add nf_reset here too, which would 
be perfectly sane.

I'm tempted to avoid the question marks hanging over generic skb_orphan for 
now, and just do skb_orphan & nf_reset at the head of our driver.

Then look at making skb_orphan do nf_reset.  It makes sense, but I'd have to 
audit all the callers.

Thanks.
Rusty.


