From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: SIOCETHTOOL ioctl() and a corrupted cmd argument
Date: Wed, 5 Mar 2003 16:41:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305214155.GM13420@gtf.org>
References: <20030305210047.GA10824@ducksong.com> <20030305213205.GA1227@ducksong.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Patrick R. McManus" <mcmanus@ducksong.com>
Content-Disposition: inline
In-Reply-To: <20030305213205.GA1227@ducksong.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 05, 2003 at 04:32:05PM -0500, Patrick R. McManus wrote:
> but SIOCETHTOOL shouldn't need perms, right? it has some functionality
> that needs it and some that doesn't, and the driver sorts it
> out.. there isn't a GIOCETHTOOL at all..
> 
> #define ETHTOOL_GSET        0x00000001 /* Get settings. */
> #define ETHTOOL_SSET        0x00000002 /* Set settings, privileged. */


You are correct that comment is misleading... all ethtool does current
requiring CAP_NET_ADMIN.  This is one of the costs of lumping things
under one ioctl, rather than constantly using new ioctls.

It is certainly possible (and reasonable) that a future kernel peeks at
the ioctl and then conditionally checks privs, but this is not currently
the case.

	Jeff
