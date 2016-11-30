From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 V3 3/3] tc/act_tunnel: Introduce ip tunnel
 action
Date: Wed, 30 Nov 2016 15:44:53 +0100
Message-ID: <20161130154453.3394b3f2@griffin>
References: <20161130073840.5269-1-amir@vadai.me>
        <20161130073840.5269-4-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757187AbcK3Oo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 09:44:58 -0500
In-Reply-To: <20161130073840.5269-4-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2016 09:38:40 +0200, Amir Vadai wrote:
> +The
> +.I UNSET
> +mode is optional - even without using it, the metadata information will be
> +released automatically when packet processing will be finished.
> +.IR UNSET
> +function could be used in cases when traffic is forwarded between two tunnels,
> +where the metadata from the first tunnel will be used for encapsulation done by
> +the second tunnel.

This looks good.

> +It must be used for offloaded filters, such that hardware drivers can
> +realize they need to program the HW to do decapsulation.

However, this is wrong. The hardware offloading must be transparent.
The same configuration that works when processed in software must work
in hardware if the hardware has the necessary capabilities. Requiring
the user to alter the configuration to accommodate hardware
peculiarities is not acceptable.

Or maybe I'm misunderstanding what you mean here. In which case it's
not documented properly :-)

> +.IR SET
> +mode requires the source and destination ip
> +.I ADDRESS
> +and the tunnel key id
> +.I KEY_ID
> +which will be used by the ip tunnel shared device to create the tunnel header. The
> +.B tunnel_key
> +action is useful only in combination with a
> +.B mirred redirect
> +action to a shared IP tunnel device which will use the metadata (for
> +.I SET
> +) and unset the metadata created by it (for
> +.I UNSET
> +).
> +
> +.SH OPTIONS
> +.TP
> +.B unset
> +Decapsulation mode, no further arguments allowed. This function is not
> +mandatory and might be used only in some specific use cases.

This is NOT decapsulation. The packet is decapsulated at this point in
any case, whether or not set/unset or whatever is used. These actions
are only and solely about metadata associated with the packet. The
actual encapsulation and decapsulation happens at the target netdevice.

Calling this "decapsulation" is wrong. And if it's implemented as such
in your hardware offloading, then it's doubly wrong as it doesn't match
software processing and hence you must not do that and you must change
that.

> +.TP
> +.B set
> +Encapsulation mode. Requires

Likewise, this is not encapsulation. It just sets metadata.

 Jiri
