From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio_net: Set correct gso->hdr_len
Date: Fri, 5 Jun 2009 16:20:02 +0930
Message-ID: <200906051620.02868.rusty@rustcorp.com.au>
References: <20090604105917.GA28273@gondor.apana.org.au> <200906051351.06385.rusty@rustcorp.com.au> <20090605042709.GA6702@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56274 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250AbZFEGuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 02:50:06 -0400
In-Reply-To: <20090605042709.GA6702@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Jun 2009 01:57:09 pm Herbert Xu wrote:
> On Fri, Jun 05, 2009 at 01:51:05PM +0930, Rusty Russell wrote:
> > But are we allowed to make the assumption that skb_headlen() ==
> > skb_transport_header(skb) + sizeof(transport header) ?  Or should we be
> > checking that here?
>
> We don't care.  We just want to preserve whatever the OS gave us.
> If it's bogus, the backend will reject it or fix it up.

Right, understood now.  It really is just a hint as to how much to copy.  It 
wasn't supposed to be that, as virtio_net.h:

	__u16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
	__u16 gso_size;		/* Bytes to append to hdr_len per frame */

The host was supposed to be able to de-gso packets together relying on 
hdr_len.  But that's silly: it can't do TSO without knowing about sequence 
numbers at least, and UFO without ip fragmentation offsets.  ie. it might as 
well calc hdr_len itself.

I'm working on a proper spec, I'll be sure to note this.

Thanks,
Rusty.
