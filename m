From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 3440] New: eth0 freezes: "NETDEV WATCHDOG: eth0: transmit
 timed out "
Date: Wed, 22 Sep 2004 14:19:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922141922.41bb9288@dell_ss3.pdx.osdl.net>
References: <20040922092713.18711d2d@dell_ss3.pdx.osdl.net>
	<BJEDLIFMBCLIGJJBNCLJGEDBCPAA.per.sil@gmx.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Perolo Silantico" <per.sil@gmx.it>
In-Reply-To: <BJEDLIFMBCLIGJJBNCLJGEDBCPAA.per.sil@gmx.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 23:03:32 +0200
"Perolo Silantico" <per.sil@gmx.it> wrote:

> Dear Stephen Hemminger,
> 
> OK, it seems you are right - it is a driver problem.
> I added the modules 3c59x and pcnet32 to the kernel (2.6.8.1)
> Transfer is fine with 3c59x (3Com 905B) and with pcnet32.
> The EtherExpress Pro 100 works perfectly on another server with kernel 2.4.23 (e100). Hence I retestet it on this machine. It works perfectly too, now. I rotated all the PCI cards between my testing machines to test various kernel/card combinations and connections. Noting wrong with eepro100 and 3c59x module on 2.6.8.1.
> 
> During the hours of testing I must have overseen some mistake of mine with all these devices in the machine - I am very sorry :(
> 
> Using the 8139too driver the interface freezes after some seconds of full bandwidth transfer. It seems to be a problem with this module. I'll  try to close the bug - Now that the problem is pinned down to one device I need more testing to ensure this is not a hardware problem. This takes quite some time and I will file a new bug if the device is OK and the driver is the problem.

On some systems the 8139too card interrupt is configured as edge (not level triggered) and
this can cause the problem because in 2.6 version of the driver it uses NAPI to avoid doing
lots of work in interrupt context.  For NAPI to work properly, the interrupt needs to be level
triggered to avoid races. Check the BIOS settings, it may be possible to change the interrupt
behaviour there.
