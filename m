From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPU
 load
Date: Tue, 17 Sep 2002 16:15:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D878D79.20904@mandrakesoft.com>
References: <OF5FEED16C.9C2ED639-ON88256C37.006CA80A@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Cureington, Tony" <tony.cureington@hp.com>,
   Andrew Morton <akpm@digeo.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 
>       Well, now that it's been pointed out to me, that does look pretty
> grotty.  It works because MII_LINK_READY is defined to be 4, and the return
> from bond_check_dev_link() is always a bitwise test against MII_LINK_READY,
> so it works.  Could be cleaner, though.

Yep.  Sounds like you also might want to replace a non-standard constant 
(MII_LINK_READY) with its standard constant from linux/mii.h, 
BMSR_LSTATUS, too, if you are going to use it like this.


>       As far as netif_carrier_ok() goes, is it reliable?  In looking at the
> drivers, it appears that some don't update the flag (e.g., 3c59x.c).

No.  Only some drivers implement it at present -- though all should. 
Patches to fix up drivers to use netif_carrier_{on,off} would be very 
welcome.  There are several examples in-tree to emulate...

	Jeff
