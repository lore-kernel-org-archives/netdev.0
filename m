From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Wed, 12 Nov 2003 20:48:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112204804.B968@sygehus.dk>
References: <Pine.LNX.4.44.0307091816280.1313-100000@hl.kauneta.net> <20030709152814.GC15293@gtf.org> <20031022140624.A9145@vip.cybercity.dk> <3F96B7FD.7080607@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <3F96B7FD.7080607@candelatech.com>; from greearb@candelatech.com on Wed, Oct 22, 2003 at 10:01:49AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 22, 2003 at 10:01:49AM -0700, Ben Greear wrote:
> Rask Ingemann Lambertsen wrote:
> > 
> > What does a driver need to do to make sure it can handle vlan frames? Is it
> > enought to be prepared to handle frames of size dev->mtu+4? How do I know 4
> > bytes will be enough tomorrow when someone introduces VLAN2 with a 64-bit tag?
> > Checking for CONFIG_VLAN is of no use, right?
> 
> It needs to be able to handle 1518 bytes (+crc), send and receive.  I'd
> suggest using the Intel e100 or e1000, as they both support VLANs just fine.
> Most other GigE nics work too.

I was thinking about what to do as a driver *writer* rather than as a driver
*user*.

#include <linux/if_vlan.h>

and allocating buffers of (dev->mtu + VLAN_ETH_HLEN) bytes. Some chips, such
as the Tulip series, need an extra 4 bytes for the CRC when receiving.

-- 
Regards,
Rask Ingemann Lambertsen
