From: Andrew Morton <akpm@digeo.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPUload
Date: Tue, 17 Sep 2002 13:30:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D8790D6.68927887@digeo.com>
References: <72A87F7160C0994D8C5A36E2FDC227F502B3E70D@txnexc01.americas.cpqcorp.net> <3D878675.3000403@mandrakesoft.com> <3D878841.EB580DE9@digeo.com> <3D878C56.2070400@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(bonding-devel didn't like the size of the attachment.
 It's at http://www.zip.com.au/~akpm/3c59x.c-netif)

Jeff Garzik wrote:
> 
> Andrew Morton wrote:
> > Jeff Garzik wrote:
> >
> >>...
> >>Also, a further question:  do you have access to the slave struct
> >>net_device?  If so, just test netif_carrier_ok(slave_dev) and avoid all
> >>that ioctl calling if it returns non-zero.
> >
> >
> > Make that "avoid all that ioctl calling from interrupt context", which
> > is a bug.  Of the box-killing variety ;)
> 
> Indeed.  /me looks at the bond_check_dev_link callers more closely and
> shudders.
> 
> That wants fixing...
> 
> Note that netif_carrier_ok() can indeed be checked in interrupt context.
>   And if someone wants to send me patches converting more drivers to use
> netif_carrier_{on,off}, I would be very happy :)

That would be best.

I'm so slack.  I received the below two years ago; Nelson has
added netif_carrier_foo support to 3c59x.c.  As Jeff says: patches
solicited.

-------- Original Message --------
Subject: Re: netlink
Date: Wed, 14 Jun 2000 11:19:33 +0800 (SST)
From: Nelson <tanginhw@comp.nus.edu.sg>
To: Andrew Morton <andrewm@uow.edu.au>
References: <394610FF.4052CEAA@uow.edu.au>

hi Andrew,

The modified 3c59x.c is attached.

for your easy reference, these lines in the attached driver 
was modified:

69-72:		notes on what are added
121-123:	defined the time to expiry of the vertex_timer
		as TX_EXPIRE. i have set the value as 1*HZ.
		the original value should be 60*HZ. you may
		set to any value you feel is good ;p you r rite
		abt the 1 sec part since reading the MII management
		registers is time consuming.
1122:		used TX_EXPIRE instead
1335, 1399, 1428:		
		set next_tick to TX_EXPIRE
1351:		added calls to netif_carrier_on()
1356:		added calls to netif_carrier_off()
1367-1371:	added checking of link state

do let me know if there are any discrepencies.
thanx.
