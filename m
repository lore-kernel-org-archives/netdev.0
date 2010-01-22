From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: VLAN vs bridging receive precedence
Date: Sat, 23 Jan 2010 10:26:18 +1300
Message-ID: <20100122212618.GA3582@gondor.apana.org.au>
References: <20100122031153.GA26565@gondor.apana.org.au> <1264180303.2784.19.camel@achroite.uk.solarflarecom.com> <20100122201331.GA2974@gondor.apana.org.au> <1264192497.2784.31.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58303 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750831Ab0AVV0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 16:26:35 -0500
Content-Disposition: inline
In-Reply-To: <1264192497.2784.31.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2010 at 08:34:56PM +0000, Ben Hutchings wrote:
. 
> As I said, it attaches a bridge interface to each NIC (physical
> interface) to start with - whether or not the administrator chooses to
> bridge the NIC to any guest interfaces.  So it doesn't work without VLAN
> receive acceleration.

That should work fine, as long as it doesn't also attach a VLAN
device to the same physical device.  The VLAN device should instead
be attached to the bridge device.

No you won't get VLAN acceleration, but really the cost wouldn't
be worth it anyway.

> And if you are going to mix them, on a virtualised server you may want
> to bridge them both to guests, separately.  That seems to require either
> that a VLAN interface and a bridge interface can be attached to the
> physical interface, with the VLAN interface taking precedence on
> receive; or that a virtual interface accepting only untagged traffic can
> be attached to the physical interface.

You mean you want to bridge both the physical device and VLAN
devices on top of it? Again it works fine if you set it up right.
You first create a bridge which includes the physical device,
then you add a VLAN on top of the bridge, and not the physical
device, finally you bridge that VLAN device.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
