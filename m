From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9545] New: Cannot bring up a bridge interface
 without a MAC address set
Date: Tue, 11 Dec 2007 21:36:59 -0800
Message-ID: <20071211213659.42591478@freepuppy.rosehill>
References: <bug-9545-10286@http.bugzilla.kernel.org/>
	<20071211132614.5854b0f1.akpm@linux-foundation.org>
	<20071211145243.66e1f66a@freepuppy.rosehill>
	<20071212015105.GB20618@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berrange@redhat.com,
	Jeff Garzik <jeff@garzik.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53758 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757463AbXLLFja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 00:39:30 -0500
In-Reply-To: <20071212015105.GB20618@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 09:51:05 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Dec 11, 2007 at 02:52:43PM -0800, Stephen Hemminger wrote:
> >
> > The tap devices have to have addresses don't they. So bringing up an empty
> > bridge is meaningless. If you just add the device first then it will work.
> 
> Actually bringing up a bridge with no constituents is useful for
> a bridge that's made up of only virtual interfaces.  Since each
> vritual interface may be created or destroyed at run-time it'd
> be quite awkward to check every time to see if that's the last
> or first and act differently on the bridge.
> 
> More importantly constiuents can be added to and removed from a
> bridge without taking it down.
> 
> > Could be fixed to prevent errors from existing scripts but it is not a complete showstopper.
> 
> Well this stops FC8 working with Xen so for that it's a showstopper :)
> 
> > The problem is that when device is brought up it propogates events up to
> > other layers and applications, these layers will then query and see a bogus
> > address.
> 
> What exactly would it break for this scenario though?

Well with earlier kernels, ipv6 and others would see an invalid address (all zeros).
That could be a problem if some netlink watching program or udev script
propagated that value into a database or management interface. But now
using a random value, that won't happen.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
