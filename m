From: "Perolo Silantico" <per.sil@gmx.it>
Subject: Re: [Bug 3440] New: eth0 freezes: "NETDEV WATCHDOG: eth0: transmit timed out "
Date: Wed, 22 Sep 2004 23:03:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BJEDLIFMBCLIGJJBNCLJGEDBCPAA.per.sil@gmx.it>
References: <20040922092713.18711d2d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Stephen Hemminger" <shemminger@osdl.org>, <per.sil@gmx.it>,
        <john.ronciak@intel.com>, <ganesh.venkatesan@intel.com>,
        <scott.feldman@intel.com>
In-Reply-To: <20040922092713.18711d2d@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear Stephen Hemminger,

OK, it seems you are right - it is a driver problem.
I added the modules 3c59x and pcnet32 to the kernel (2.6.8.1)
Transfer is fine with 3c59x (3Com 905B) and with pcnet32.
The EtherExpress Pro 100 works perfectly on another server with kernel 2.4.23 (e100). Hence I retestet it on this machine. It works perfectly too, now. I rotated all the PCI cards between my testing machines to test various kernel/card combinations and connections. Noting wrong with eepro100 and 3c59x module on 2.6.8.1.

During the hours of testing I must have overseen some mistake of mine with all these devices in the machine - I am very sorry :(

Using the 8139too driver the interface freezes after some seconds of full bandwidth transfer. It seems to be a problem with this module. I'll  try to close the bug - Now that the problem is pinned down to one device I need more testing to ensure this is not a hardware problem. This takes quite some time and I will file a new bug if the device is OK and the driver is the problem.

I am very sorry that I have taken your time. 
Yours
  Perolo

> -----Ursprungliche Nachricht-----
> From: Stephen Hemminger [mailto:shemminger@osdl.org]
> Date: Mittwoch, 22. September 2004 18:27
> To: per.sil@gmx.it; john.ronciak@intel.com; ganesh.venkatesan@intel.com;
> scott.feldman@intel.com
> Cc: netdev@oss.sgi.com
> Subject: Re: [Bug 3440] New: eth0 freezes: "NETDEV WATCHDOG: eth0:
> transmit timed out "
> 
> 
> This is an ethernet driver related problem.  Which of the 
> ethernet cars (PCNet32 or E100)
> is assigned to eth0?  And which of the two e100 drivers (e100 or 
> eepro100) are you using?
> 
> 
> On Tue, 21 Sep 2004 09:42:06 -0700
> bugme-daemon@osdl.org wrote:
> 
> > http://bugme.osdl.org/show_bug.cgi?id=3440
> > 
> >            Summary: eth0 freezes: "NETDEV WATCHDOG: eth0: 
> transmit timed out
> >                     "
> >     Kernel Version: 2.6.8.1
> >             Status: NEW
> >           Severity: high
> >              Owner: shemminger@osdl.org
> >          Submitter: per.sil@gmx.it
> > 
> > 
> > Hi kernel developers,
> > 
> > There exists a severe problem with a linux box of my own. The 
> problem does not
> > occur when using kernel 2.4.25 on the same machine. I need your help.
> > 
> > Distribution:
> > -------------
> > Gentoo Linux 1.4 (2004.2), recompiled whole system with kernel 
> 2.6 and NPTL.
> > 
> > Hardware Environment:
> > ---------------------
> > - IBM PC Server 325, Dual Pentium Pro 180MHz, 256MB RAM, 
> > - 3ware Controller 6410 with RAID 1+0, 
> > - PCNet32 10MBit on-board card
> > - Intel EtherExpress Pro 100
> > - RTL 8139 Card. 
> > - 2x AVM ISDN B1 active ISA cards (Rev. 2.0 and Rev. 3.0 cards)
> > 
> > Tried with both cards, and tried both manually set to half-duplex or
> > full-duplex. tried same kernel with ISDN cards removed (but 
> modules still
> > compiled in)
> > 
> > I removed one processor using same SMP-enabled kernel on single 
> processor system
> > - problem persists.
> > 
> > The box is connected to a DLink DGS-1008D GigaBit switch and I 
> tried with a
> > D-Link DES 1026G switch.
> > 
> > 
> > The source of the transfer is a HP Netserver Dual Pentium III 
> 600MHz with kernel
> > 2.4.23_pre8 SMP and same openSSH version, connected to the same switch.
> > 
> > 
> > Software Environment:
> > ---------------------
> > "vanilla" kernel 2.6.8.1 on Gentoo Linux (see dmesg output and 
> config file)
> > IPv6 compiled in but deactivated with
> >   ifconfig eth1 inet6 del ...
> > 
> > same problem with kernel 2.6.7 and 2.6.8 using same kernel 
> configuration.
> > 
> > gcc-3.3.4
> > glibc-2.3.4.20040808  
> > OpenSSH_3.8.1p1, OpenSSL 0.9.7d 17 Mar 2004
> > 
> > (for installed system utils, see attached file)
> > 
> > Problem Description:
> > ---------------------
> > 
> > When transfering some data (approx. 3 GB in size) from one 
> amchine on the LAN to
> > this box the transmission hangs on the interface after some 
> seconds (20MBs) and
> > a "time out" occures. Then the LAN connection freezes, is 
> terminated and the
> > linux box is not reachable from the network anymore. After some 
> minutes the
> > connection recoveres again.
> > 
> > The network transmission times out and the ethernet driver is 
> not responding to
> > any LAN traffic (not even to any ICMP echo request). kernel log 
> message tells:
> > 
> >    NETDEV WATCHDOG: eth0: transmit timed out
> >    eth0:  Tx descriptor 0 is 0008a072.
> > 
> > (off course: address of descriptor varies)
> > After approx. 4 minutes, the LAN connection of the box recovers 
> and you can
> > connect to the box again. (until next transfer is started)
> > 
> > transfer issued by another host:
> > ................................
> > Usually a transfer host consumes all interface bandwidth 
> available (100 MBit LAN
> > with full-duplex cards on both involved machines gives at least 
> 1.6 MByte/s if
> > SCP overhead is taken into consideration). the connection stays 
> alive if it
> > limited to smaller bandwith with fe. 100 Kbit (~ 12.5 KBytes) 
> "scp -l 100 ...".
> > But using 1000 KBit (~125 KByte) "scp -l 1000 ..." the 
> connection is freezing
> > although maximum bandwidth is not reached. 
> > 
> > transfer issued by host itself:
> > ................................
> > If the box issues a transfer from the internet using 235 
> KBytes/s (~ 2MBits/s)
> > everything works out fine. If the box issues the transfer from 
> the LAN with full
> > bandwith of 1.8 MBytes/s then the LAN connection is freezing too. 
> > 
> > 
> > If I turn of window scaling with "echo 0 >
> > /proc/sys/net/ipv4/tcp_window_scaling" then the time needed to 
> recover the
> > interface seems to decrease. The SCP transfer still freezes but 
> LAN timeout of
> > the box is small enough to keep SSH connection alive.
> > 
> > it did not help to set the following, as suggested by other web pages:
> >   tcp_default_win_scale=0
> >   tcp_moderate_rcvbuf=0
> > 
> > 
> > Steps to reproduce:
> > -------------------
> > start any SCP/SFTP transfer to the linux box with kernel 
> 2.6.8.1 - always
> > reproducable on my box. I do not know about others since this 
> is my first box
> > with kernel 2.6.x
> > 
> > 
> > 
> > If you need more information or testing, please let me know. I 
> will not change
> > the configuration of the box for some time to be able to 
> fullfill your requests,
> > hoping to help solving the problem. 
> > 
> > 
> > Yours
> >   Perolo
> > 
> > PS: Dear maintainer, I am able to grant you access to the 
> computer if this will
> > help you. please contact me if this is vital for solving the problem.
> > 
> > ------- You are receiving this mail because: -------
> > You are the assignee for the bug, or are watching the assignee.
> 
