From: "Jay Vosburgh" <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPUload
Date: Tue, 17 Sep 2002 13:37:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF335D980B.45B33AA4-ON88256C37.006F0399@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@digeo.com>,
   "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



      Ok.  I'll whip up a patch either this afternoon or tomorrow (gotta
download 2.4.20-pre7, no broadband here) that de-uglifies the badness
around magic number 4 and includes one of the ioctl in a context patches
(which may not fix everything properly, but should be better than what's
there now).

      I'm not sure about throwing in a test of netif_carrier_ok() just for
good measure. It looks like if the driver does not support
netif_carrier_xxx, then the default will be carrier on (because the bit is
clear in dev->state).  So, we can ask, and if it tells us the carrier is
down, that's probably reliable, but if it says carrier is up, that may or
may not be true.  Or am I missing an initialization in there somewhere?

      And, actually, the bonding driver is already using netif_carrier_ok()
as part of the IS_UP() macro defined in bonding.c.  It's just not used
during the MII test.

      -J


Jeff Garzik <jgarzik@mandrakesoft.com>@lists.sourceforge.net on 09/17/2002
01:11:02 PM

Sent by:    bonding-devel-admin@lists.sourceforge.net


To:    Andrew Morton <akpm@digeo.com>
cc:    "Cureington, Tony" <tony.cureington@hp.com>, Pascal Brisset
       <pascal.brisset-ml@wanadoo.fr>, bonding-devel@lists.sourceforge.net,
       netdev@oss.sgi.com
Subject:    Re: [Bonding-devel] Re: Bonding driver unreliable under high
       CPUload



Andrew Morton wrote:
> Jeff Garzik wrote:
>
>>...
>>Also, a further question:  do you have access to the slave struct
>>net_device?  If so, just test netif_carrier_ok(slave_dev) and avoid all
>>that ioctl calling if it returns non-zero.
>
>
> Make that "avoid all that ioctl calling from interrupt context", which
> is a bug.  Of the box-killing variety ;)


Indeed.  /me looks at the bond_check_dev_link callers more closely and
shudders.

That wants fixing...

Note that netif_carrier_ok() can indeed be checked in interrupt context.
  And if someone wants to send me patches converting more drivers to use
netif_carrier_{on,off}, I would be very happy :)



-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
Bonding-devel mailing list
Bonding-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/bonding-devel
