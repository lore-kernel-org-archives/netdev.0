From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9545] New: Cannot bring up a bridge interface without a MAC address set
Date: Wed, 12 Dec 2007 09:51:05 +0800
Message-ID: <20071212015105.GB20618@gondor.apana.org.au>
References: <bug-9545-10286@http.bugzilla.kernel.org/> <20071211132614.5854b0f1.akpm@linux-foundation.org> <20071211145243.66e1f66a@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berrange@redhat.com,
	Jeff Garzik <jeff@garzik.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4709 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750865AbXLLBvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 20:51:13 -0500
Content-Disposition: inline
In-Reply-To: <20071211145243.66e1f66a@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 02:52:43PM -0800, Stephen Hemminger wrote:
>
> The tap devices have to have addresses don't they. So bringing up an empty
> bridge is meaningless. If you just add the device first then it will work.

Actually bringing up a bridge with no constituents is useful for
a bridge that's made up of only virtual interfaces.  Since each
vritual interface may be created or destroyed at run-time it'd
be quite awkward to check every time to see if that's the last
or first and act differently on the bridge.

More importantly constiuents can be added to and removed from a
bridge without taking it down.

> Could be fixed to prevent errors from existing scripts but it is not a complete showstopper.

Well this stops FC8 working with Xen so for that it's a showstopper :)

> The problem is that when device is brought up it propogates events up to
> other layers and applications, these layers will then query and see a bogus
> address.

What exactly would it break for this scenario though?

Cheersk,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
