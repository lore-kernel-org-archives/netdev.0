From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH iproute2 V3 3/3] tc/act_tunnel: Introduce ip tunnel action
Date: Thu, 1 Dec 2016 11:57:15 +0200
Message-ID: <20161201095715.GA28945@office.localdomain>
References: <20161130073840.5269-1-amir@vadai.me>
 <20161130073840.5269-4-amir@vadai.me>
 <20161130154453.3394b3f2@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33387 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbcLAJ5T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 04:57:19 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so33230096wmu.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 01:57:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161130154453.3394b3f2@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 03:44:53PM +0100, Jiri Benc wrote:
> On Wed, 30 Nov 2016 09:38:40 +0200, Amir Vadai wrote:
> > +The
> > +.I UNSET
> > +mode is optional - even without using it, the metadata information will be
> > +released automatically when packet processing will be finished.
> > +.IR UNSET
> > +function could be used in cases when traffic is forwarded between two tunnels,
> > +where the metadata from the first tunnel will be used for encapsulation done by
> > +the second tunnel.
> 
> This looks good.
:)

> 
> > +It must be used for offloaded filters, such that hardware drivers can
> > +realize they need to program the HW to do decapsulation.
> 
> However, this is wrong. The hardware offloading must be transparent.
> The same configuration that works when processed in software must work
> in hardware if the hardware has the necessary capabilities. Requiring
> the user to alter the configuration to accommodate hardware
> peculiarities is not acceptable.
> 
> Or maybe I'm misunderstanding what you mean here. In which case it's
> not documented properly :-)
You understood it correctly. We should not force the user to use the
'unset' operation for offloading only. I will remove it from the text
here.

> 
> > +.IR SET
> > +mode requires the source and destination ip
> > +.I ADDRESS
> > +and the tunnel key id
> > +.I KEY_ID
> > +which will be used by the ip tunnel shared device to create the tunnel header. The
> > +.B tunnel_key
> > +action is useful only in combination with a
> > +.B mirred redirect
> > +action to a shared IP tunnel device which will use the metadata (for
> > +.I SET
> > +) and unset the metadata created by it (for
> > +.I UNSET
> > +).
> > +
> > +.SH OPTIONS
> > +.TP
> > +.B unset
> > +Decapsulation mode, no further arguments allowed. This function is not
> > +mandatory and might be used only in some specific use cases.
> 
> This is NOT decapsulation. The packet is decapsulated at this point in
> any case, whether or not set/unset or whatever is used. These actions
> are only and solely about metadata associated with the packet. The
> actual encapsulation and decapsulation happens at the target netdevice.
> 
> Calling this "decapsulation" is wrong. And if it's implemented as such
> in your hardware offloading, then it's doubly wrong as it doesn't match
> software processing and hence you must not do that and you must change
> that.
Got it. Bad wording by me - will fix it and make sure offloading will
realy be transparent to user.

> 
> > +.TP
> > +.B set
> > +Encapsulation mode. Requires
> 
> Likewise, this is not encapsulation. It just sets metadata.
ack

Thanks,
Amir
> 
>  Jiri
