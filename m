From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device cleanup
Date: Sat, 7 Jun 2003 15:15:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030607191522.GB3346@gtf.org>
References: <20030606145835.3a263df8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030606145835.3a263df8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 06, 2003 at 02:58:35PM -0700, Stephen Hemminger wrote:
> This is the first phase of a sequence of patches to resolve network
> device reference count issues exposed by the new sysfs interface.
> 
> Phase I:  introduces release_netdev which is the hook to allow later
>    changes to hold onto the net device after the device has potentially
>    unloaded.  Includes patch for the easy to fix devices. 
> 
> Phase II: fixes devices that encapsulate network device structure
>    inside their own structure, or allocate private data in a way
>    that will break later.

I would prefer to fix the drivers _before_ anything else.  i.e. Phase 2
becomes Phase 1.

These often need to be merged into 2.4 as well, and they can be applied
to all drivers without any API changes.  The changes are separated out
from any refcounting/sysfs stuff, and can (potentially) be considered
and reviewed by the respective maintainers.

	Jeff
