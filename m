From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: bonding questions: carrier based link monitoring / slave device
 state flags
Date: Tue, 08 Aug 2006 16:24:20 +0300
Message-ID: <44D89084.7010002@voltaire.com>
References: <Pine.LNX.4.64.0608030815270.32510@zuben> <200608040019.k740JTZt018654@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:19883 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S964855AbWHHNYb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:24:31 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200608040019.k740JTZt018654@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:

>         I'll just note that all of the bonding parameters and such are
> documented in the Documentation/networking/bonding.txt file that comes
> with the kernel source code.  You can also download the documentation
> from sourceforge.net/projects/bonding.

Just to be clear, i have looked in Documentation/networking/bonding.txt 
before sending this question.

>         To answer your question, you'd have to specify an miimon=X
> interval (where X is some nonzero value, e.g., 100).  The default for
> the use_carrier parameter is 1, which is what you want, so there is no
> need to specify it.  The purpose of the use_carrier parameter is to
> permit the old method to be used for network drivers that don't support
> netif_carrier (which are pretty rare these days).

With old method you refer to the bonding driver using MII ioctls etc vs 
just calling netif_carrier_ok().

>  >What i want to better understand here, is whether for the bonding driver
>  >to declare a slave as "being able to carry traffic" it assumes the slave
>  >will move from UP to RUNNING state (and later netif_carrier_ok would
>  >return TRUE) without an IP address being set for the slave device ???
> 
>         The RUNNING state is set (indirectly) by the device driver when
> it calls netif_carrier_on(); this is totally unrelated to the IP address
> information attached to an interface.  Whatever IP address is set for a
> slave is not used during operation.

OK, thanks for clarifying this.

>  >Is (per the bonding driver) the **time** it should take the slave to get
>  >from UP to (RUNNING && carrier_ok) state limited and/or controlled?
> 
>         I'm not exactly sure what you're asking here, but when miimon is
> enabled, if the slave is not netif_carrier_ok() during any of the
> periodic checks, it will be disabled by the bonding driver.

The transition from being UP to having carrier might involve third party 
and hence take some time (eg in IP over Infiniband the broadcast traffic 
is carried over a dedicated IB multicast group and joining this group is 
carried by communication with the Infiniband SA). But if the bonding 
code does periodic checks, this is fine.

>         There are also updelay and downdelay parameters to handle cases
> where it takes some amount of real time for a carrier state transition
> to occur (and, thus, state changes should be ignored for a period of
> time).  E.g., some switches will assert link up on a port before they
> are actually able to send and receive traffic; in that case, bonding
> could use the updelay parameter to ignore link up changes for a period
> of time.

OK understood.

Or.

