From: Roger Heflin <rheflin@atipa.com>
Subject: Re: Nvidia MCP55 Machine reboots on ixgb driver load
Date: Wed, 24 Jan 2007 17:30:30 -0600
Message-ID: <45B7EC16.9070706@atipa.com>
References: <45B7CA3D.9020601@atipa.com> <45B7D88F.30703@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <45B7D88F.30703@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> [added netdev to CC]
> 
> Roger Heflin wrote:
>> I have a machine (actually 2 machines) that upon loading
>> the intel 10GBe driver (ixgb) the machine reboots, I am
>> using a RHAS4.4 based distribution with Vanilla 2.6.19.2
>> (the RHAS 4.4.03 kernel also reboots with the ixgb load),
>> I don't see any messages on the machine before it reboots,
>> loading the driver with debug does not appear to produce
>> any extra messages.   The basic steps are the I load
>> the driver, the machine locks up, and then in a second
>> or 2 it starts to post.
> 
> some suggestions immediately come to mind:
> 
> * have you tried the latest driver from http://e1000.sf.net/ ?

I have tried the ixgb-1.0-126 driver from intel's web site, with it doing
the same thing, and that looks to be the same as the sf driver.

> 
> * what happens when you unplug the card and modprobe the ixgb module?

That loads just fine, and prints out the driver information, and
the copyright.

> 
> * have you tried capturing a trace with netconsole or serial console? 
> probing the ixgb driver produces at least 1 syslog line that should show 
> up. If nothing shows up on serial or netconsole, the issue may be way 
> outside the ixgb driver.

I *think* have got the line listing the interrupt 1 or 2 times just
before it goes away, I got the serial crossover working to a
laptop and got no extra kernel messages when the driver was loaded
and rebooted the machine, I did see the full kernel bootup so
I know the serial console was working correctly.

> 
>> I have tried the default ixgb driver in 2.6.19.2, and I
>> have tried the open source intel driver on RH4.4, both cause
>> the same reboot.    I also tried the linux firmware
>> development kit, and booting fc6 causes the same reboot
>> upon the network driver load.
> 
> just for completeness, which driver versions were this?

The ixgb-1.0.126 driver from Intel's site.

The default driver on 4.4.03 does not support the CX4 board,
but loads just fine, just does not find any cards that it
can drive.   I did confirm that it does not list the PCIID
for the CX4 card.

> 
> and when you say "booting fc6" I assume you mean that fc6 boots OK until 
> you modprobe the ixgb driver?

Yes, that is correct the machine goes to full multiuser (I have
the .ko file moved elsewhere so automatic module loading does
not kill the machine-until it choose to test it), and has been
used for some io test with no issues until the ixgb driver is loaded.

Both machines have been heavily tested with high cpu applications
that verify their results to make sure memory is working correctly
under load.

> 
>> I have tried pci=nomsi
> 
> try compiling your kernel without MSI support alltogether. There have 
> been serious issues found with MSI on certain configurations, and in 
> your case this might be the cause. Allthough passing pci=nomsi should be 
> the same as compiling it out, it can't hurt to try.

Ok, I tried that.

I found out that breaks some other unrelated stuff, but loading the ixgb
driver still crashes the machine.

> 
>> Also note that the linux.nics@intel.com address is apparently
>> unused and returns an email telling you to use a web page,
>> and so far after using the web page I have not got any response
>> indicating that anything got to anyone.
> 
> I've taken action to get that straightened out. You're always welcome to 
> mail netdev, the e1000 devel list or even lkml which we will all pick up 
> on.
> 
> 
> I can't think of a specific reason for the issue right now, other than 
> attempting to get a serial/netconsole attached and trying without any 
> msi support in the kernel. Please give that a try and let us know.
> 

Nothing extra from the serial console, and still locks up with no
msi support.

                          Roger

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
