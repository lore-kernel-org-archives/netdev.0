From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: ifconfig up/down problem
Date: Tue, 9 Sep 2003 00:08:06 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.56.0309090004100.24700@space.comunit.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi...

Short: ifconfig ethX down locks

Kernel: 2.4.22-bk12 (same problem with 2.4.23-pre3)
eth0: eepro100
eth1: orinoco_cs (orinoco mini-pci)
System: Toshiba Satellite Pro 4600 Laptop, P3 700Mhz

Just after booting, no X startet yet, interface not yet initialized:

aurora:~# ifconfig eth1 down
aurora:~# ifconfig eth1 up
aurora:~# ifconfig eth1 down
aurora:~# ifconfig eth1 up
aurora:~# ifconfig eth1 down
<--lock here, shell does not return, even ctrl-c does not help

haegar@aurora:~$ ps axl|grep ifconfig
4     0  1041  1035   9   0  1448  404 dev_cl S    pts/0      0:00 ifconfig eth1

top shows ifconfig consuming 100% cpu, 100% system

The same happens with eth0, there it takes only two up/down cycles,
perhaps because it is already configured with ipv4+ipv6 addresses, and the
same happens using '/sbin/ip link set eth0 up/down' too.

Kernel 2.4.20-pre2-ac3 is ok (my last kernel, running for month')

c'ya
sven

ps: kernel config available under http://sdinet.de/tmp/config-2.4.22-bk12
ps2: loaded modules:
	Module                  Size  Used by    Not tainted
	input                   3328   0 (autoclean)
	ipt_limit                888  10 (autoclean)
	ipt_REJECT              3480   2
	ipt_LOG                 3416  10
	ipt_state                568  12
	ip_conntrack_ftp        4176   0 (unused)
	ip_conntrack           18116   3 [ipt_state ip_conntrack_ftp]
	iptable_filter          1740   1
	ip_tables              12448   5 [ipt_limit ipt_REJECT ipt_LOG ipt_state iptable_filter]
	orinoco_cs              4596   1
	orinoco                36116   0 [orinoco_cs]
	hermes                  7044   0 [orinoco_cs orinoco]
	ds                      6996   3 [orinoco_cs]
	acm                     6464   0 (unused)
	pwc                    44432   0 (unused)
	videodev                6048   0 [pwc]
	audio                  43256   0 (unused)
	soundcore               3652   0 [audio]
	usb-uhci               23696   0 (unused)
	ide-scsi               10320   0
	i810_rng                3200   0 (unused)
	serial                 48228   0 (autoclean)
	isa-pnp                32560   0 (autoclean) [serial]
	parport_pc             23784   1 (autoclean)
	lp                      7040   0 (autoclean)
	parport                25512   1 (autoclean) [parport_pc lp]
	sd_mod                 11180   0 (unused)
	scsi_mod               87216   2 [ide-scsi sd_mod]
	usbcore                62956   1 [acm pwc audio usb-uhci]
	yenta_socket           12928   3
	pcmcia_core            43520   0 [orinoco_cs ds yenta_socket]
	agpgart                25320   0 (unused)
	ipv6                  174100  -1
	eepro100               21972   1
	mii                     2432   0 [eepro100]
	rtc                     6792   0 (autoclean)

--

The Internet treats censorship as a routing problem, and routes around it.
(John Gilmore on http://www.cygnus.com/~gnu/)
