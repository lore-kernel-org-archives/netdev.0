From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [Bug 3440] New: eth0 freezes: "NETDEV WATCHDOG: eth0: transmit timed out "
Date: Wed, 22 Sep 2004 10:50:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922175039.GA14542@us.ibm.com>
References: <20040922092713.18711d2d@dell_ss3.pdx.osdl.net> <BJEDLIFMBCLIGJJBNCLJGECPCPAA.per.sil@gmx.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, scott.feldman@intel.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Perolo Silantico <per.sil@gmx.it>
Content-Disposition: inline
In-Reply-To: <BJEDLIFMBCLIGJJBNCLJGECPCPAA.per.sil@gmx.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In looking at the dmesg log for bug 3440, it looks like eth0 is a
RealTek adapter and eth1 is an eepro100.

"8139too Fast Ethernet driver 0.9.27
eth0: RealTek RTL8139 at 0xd0842000, 00:50:fc:4c:d6:9b, IRQ 9
eth0:  Identified 8139 chip type 'RTL-8139C'"

"eepro100.c:v1.09j-t 9/29/99 Donald Becker
http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin
<saw@saw.sw.com.sg> and others
eth1: 0000:00:0e.0, 00:A0:C9:43:8C:E4, IRQ 15."

Another way to verify which driver is associated with a device name is
to use 'ethtool -i eth0'.  This will report the driver name and version
of the driver.

If the same problems happens with the pcnet32 driver, I can help you
debug the problem with the pcnet32.


On Wed, Sep 22, 2004 at 06:45:12PM +0200, Perolo Silantico wrote:
> Same behaviour for drivers:
>   - 8139too (kernel 2.6.8.1 and 2.6.8)
>   - e100 (kernel 2.6.8)
>   - eepro100 (kernel 2.6.8.1)
> 
> I have tried with all these drivers. Therefore it seemed to me, that this is not related to any specific driver. But to be sure, I will grab a 3com 905C from another server and try with that one and will try with the PCNet32 too.
> 
> > 
> > From: Stephen Hemminger [mailto:shemminger@osdl.org]
> > Sent: Mittwoch, 22. September 2004 18:27
> > To: per.sil@gmx.it; john.ronciak@intel.com; ganesh.venkatesan@intel.com;
> > scott.feldman@intel.com
> > Cc: netdev@oss.sgi.com
> > Subject: Re: [Bug 3440] New: eth0 freezes: "NETDEV WATCHDOG: eth0:
> > transmit timed out "
> > 
> > 
> > This is an ethernet driver related problem.  Which of the 
> > ethernet cars (PCNet32 or E100)
> > is assigned to eth0?  And which of the two e100 drivers (e100 or 
> > eepro100) are you using?
> > 
> > 
> > On Tue, 21 Sep 2004 09:42:06 -0700
> > bugme-daemon@osdl.org wrote:
> > 
> > > http://bugme.osdl.org/show_bug.cgi?id=3440
> > > 
> > >            Summary: eth0 freezes: "NETDEV WATCHDOG: eth0: 
> > transmit timed out
> > >                     "
> > >     Kernel Version: 2.6.8.1
> > >             Status: NEW
> > >           Severity: high
> > >              Owner: shemminger@osdl.org
> > >          Submitter: per.sil@gmx.it
> > > 
> > > 
-- 
Don Fry
brazilnut@us.ibm.com
