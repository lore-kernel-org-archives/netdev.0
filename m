From: Jim Keniston <jkenisto@us.ibm.com>
Subject: Re: [PATCH 2.6.1] Net device error logging
Date: Tue, 20 Jan 2004 15:06:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400DB46D.67E852D9@us.ibm.com>
References: <400C3D3E.BFCC25CE@us.ibm.com> <20040120195122.A1087@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
        Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        "Feldman, Scott" <scott.feldman@intel.com>,
        Larry Kessler <kessler@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> 
> On Mon, Jan 19, 2004 at 12:25:34PM -0800, Jim Keniston wrote:
> > The enclosed patch implements the netdev_* error-logging macros for
> > network drivers.  These macros have been discussed at length on the
> > linux-kernel and linux-netdev lists.  All issues that reviewers have
> > raised were addressed previously.  This is just an update for v2.6.1.
> 
> How about a message rate limit?
> 
> --
> Regards,
> Rask Ingemann Lambertsen

Thanks.  We considered adding a ratelimit flag to the netdev_printk arg
list.  It was pointed out that
(1) rate-limiting is necessary for a relatively small subset of messages;
and
(2) the NETIF_MSG_* flags are already designed to be used in order of
increasing verbosity.  If the user selects the more verbose class of
messages, then rate-limiting may not be appropriate.

I concluded that ratelimit() should continue to be used on a case-by-case
basis, and not folded into netdev_printk.

Jim Keniston
