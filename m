From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Minimum MTU Mess
Date: Mon, 12 Sep 2016 10:31:10 -0400
Message-ID: <20160912143110.GN20632@redhat.com>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
 <08e44341-cfcd-5644-8e23-f7348de376b2@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38698 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754160AbcILObP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 10:31:15 -0400
Received: by mail-wm0-f47.google.com with SMTP id 1so148237717wmz.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 07:31:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <08e44341-cfcd-5644-8e23-f7348de376b2@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 11:59:41AM +0900, YOSHIFUJI Hideaki wrote:
> 
> 
> Jarod Wilson wrote:
> > On Tue, Sep 06, 2016 at 04:55:29PM -0700, David Miller wrote:
> >> From: Jarod Wilson <jarod@redhat.com>
> >> Date: Fri, 2 Sep 2016 13:07:42 -0400
> >>
> >>> In any case, the number of "mtu < 68" and "#define FOO_MIN_MTU 68", or
> >>> variations thereof, under drivers/net/ is kind of crazy.
> >>
> >> Agreed, we can have a default and let the different cases provide
> >> overrides.
> >>
> >> Mostly what to do here is a function of the hardware though.
> > 
> > So I've been tinkering with this some, and it looks like having both
> > centralized min and max checking could be useful here. I'm hacking away at
> > drivers now, but the basis of all this would potentially look about like
> > the patch below, and each device would have to set dev->m{in,ax}_mtu one
> > way or another. Drivers using alloc_etherdev and/or ether_setup would get
> > the "default" values, and then they can be overridden. Probably need
> > something to make sure dev->max_mtu isn't set to 0 though...
> > 
> > Possibly on the right track here, or might there be a better way to
> > approach this?
> > 
> > diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
> > index 117d02e..864d6f2 100644
> > --- a/include/uapi/linux/if_ether.h
> > +++ b/include/uapi/linux/if_ether.h
> > @@ -35,6 +35,8 @@
> >  #define ETH_FRAME_LEN	1514		/* Max. octets in frame sans FCS */
> >  #define ETH_FCS_LEN	4		/* Octets in the FCS		 */
> >  
> > +#define ETH_MIN_MTU	68		/* Min IPv4 MTU per RFC791	*/
> > +
> >  /*
> >   *	These are the defined Ethernet Protocol ID's.
> >   */
> 
> Why don't we disable IPv4 if the MTU is lower than this value
> as we do for IPv6?

What will you be left with that is actually usable? Quite a few NIC
drivers already enforce this as a minimum MTU, and for drivers that really
want to allow less, they just set min_mtu to whatever they like. I'm
actually aiming to be 100% functionally identical wrt all existing minimum
mtu checks already in existence, just trying to improve how they're done.

-- 
Jarod Wilson
jarod@redhat.com
