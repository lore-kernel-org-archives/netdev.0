From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio: indirect ring entries (VIRTIO_RING_F_INDIRECT_DESC)
Date: Sun, 17 May 2009 23:46:12 +0930
Message-ID: <200905172346.14498.rusty@rustcorp.com.au>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com> <200905171134.31285.rusty@rustcorp.com.au> <4A0FAE35.3040608@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>, dlaor@redhat.com,
	netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44871 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbZEQOQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 10:16:16 -0400
In-Reply-To: <4A0FAE35.3040608@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 May 2009 03:57:01 pm Avi Kivity wrote:
> Rusty Russell wrote:
> > +static void adjust_threshold(struct vring_virtqueue *vq,
> > +			     unsigned int out, unsigned int in)
> > +{
> > +	/* There are really two species of virtqueue, and it matters here.
> > +	 * If there are no output parts, it's a "normally full" receive queue,
> > +	 * otherwise it's a "normally empty" send queue. */
>
> This comment is true for networking, but not for block. ++overkill with
> a ->adjust_threshold op.

No, it's true for block.  It has output parts, so we should reduce threshold 
when it's full.  Network recvq is an example which should reduce threshold 
when it's empty.

->adjust_threshold is better as an arg to vring_new_virtqueue, but it's still 
not clear what the answer would be.

Rusty.

