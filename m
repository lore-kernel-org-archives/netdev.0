From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [6/6] [VIRTIO] net: Allow receiving SG packets
Date: Tue, 22 Apr 2008 12:50:27 +1000
Message-ID: <200804221250.27909.rusty@rustcorp.com.au>
References: <20080418032142.GD18071@gondor.apana.org.au> <200804220506.16887.rusty@rustcorp.com.au> <20080421.130418.01258045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	herbert@gondor.apana.org.au, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57641 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758202AbYDVCuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 22:50:32 -0400
In-Reply-To: <20080421.130418.01258045.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 April 2008 06:04:18 David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Tue, 22 Apr 2008 05:06:16 +1000
>
> > I'm not sure what the right number is here.  Say worst case is header
> > which goes over a page boundary then MAX_SKB_FRAGS in the skb, but for
> > some reason that already has a +2:
> >
> > /* To allow 64K frame to be packed as single skb without frag_list */
> > #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
> >
> > Unless someone explains, I'll change the xmit sg to 2+MAX_SKB_FRAGS as
> > well.
>
> MAX_SKB_FRAGS + 1 is what you ought to need.

Right, and so that's +2 for virtio_net because we have an extra header as  
Herbert points out.

But I was curious as to why the +2 in the MAX_SKB_FRAGS definition?

Thanks,
Rusty.
