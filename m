From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: csum offload and af_packet
Date: Tue, 12 Aug 2008 12:27:43 +1000
Message-ID: <200808121227.43732.rusty@rustcorp.com.au>
References: <E1KSU3v-00037r-00@gondolin.me.apana.org.au> <200808112350.25514.rusty@rustcorp.com.au> <20080812003244.GA18230@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48258 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466AbYHLC17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 22:27:59 -0400
In-Reply-To: <20080812003244.GA18230@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 August 2008 10:32:44 Herbert Xu wrote:
> On Mon, Aug 11, 2008 at 11:50:25PM +1000, Rusty Russell wrote:
> > I think this is deeper than that.  This case is actually unusual, in that
> > the packet really does arrive with a partial csum.  But usually, we're
> > exposing an internal detail of our stack at this point.  Seems like we
> > shouldn't if we know the user can't deal with it.  dhcpd just makes this
> > case less academic.
>
> I disagree.  If you're using AF_PACKET you're asking to see the
> bare details.  If you want to see the censored version you can
> always go through the IP stack.

Then should we insist the user set PACKET_AUXDATA?  Even then, the format of 
that cmsg will have to be enhanced as we change kernel internals.  Which is 
probably why you *don't* get to see the bare details: you get a flag 
saying "oh, I know the checksum is bad".  Without the csum_start/csum_offset 
fields you can't even calculate what it will be.

The dhcp client thing is a symptom which can be fixed, but are we doing the 
right thing?  (Tho for lguest this is a new problem with the current kernel, 
so fixing it now means it really wouldn't be a problem).

> > We can trivially disable it in the guest or host; that's not the problem.
> >  We can even disable csum offload just for UDP in the host.  But should
> > we really?
>
> It's not about disabling it, it's about enabling it dynamically
> once guest user-space is sure that *it* can handle this.

Oh, I see.  I'd have to think harder; I'm not sure if we have all the pieces 
at the moment for virtio or would need a boutique mechanism for this (usually 
the host doesn't change the features it offers, even if device resets).  May 
be easier to suppress csum offload for dhcp packets in the host...

Rusty.
