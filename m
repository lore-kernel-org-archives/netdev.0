From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 12 Jan 2010 03:49:45 -0800 (PST)
Message-ID: <20100112.034945.26010501.davem@davemloft.net>
References: <20100112.032054.138911601.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752192Ab0ALLtj@vger.kernel.org>
In-Reply-To: <20100112.032054.138911601.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 12 Jan 2010 03:20:54 -0800 (PST)

Forgot to CC: the lists on this one, sorry about that,
fixed...

> A bunch of small changes fixing real bugs.  Many of which
> have bugzilla/regression list references.  This is what has
> accumulated since my last pull request around Dec 29th...
> 
> Outside of the SCTP warning, ROSE VC number handling, mc_loop, and the
> af_packet fixes, it's all in drivers in one way or another.  Even the
> mc_loop fix is technically a driver fix since the problem occurs with
> tunnels :-)
> 
> 1) Leaks and MAC address fixes in netxen from Amit Kumar Salecha
> 
> 2) SCTP warning fix from Andrew Morton.
> 
> 3) Several trivial fixes from Roel Kluin:
> 
>    USBNET, NIU, SH_ETH, and ATARILANCE have off by one tests
>    broadcom PHY driver confuses || and && in test
>    
> 4) cs89x0 request_irq() errors cause driver to fail to come up,
>    so always report that, don't do it unconditionally.  From
>    Mark Brown.
> 
> 5) Add CIS entries for some pcmcia network/serial devices, from Ken
>    Kawasaki.
> 
> 6) netstamp_needed counter is corrupted (it goes negative) because we
>    forget to bump it when cloning children from a listening socket
>    when it has timestamps enabled.
> 
>    Fix from Octavian Purdila.
> 
> 7) mc_loop checks in tunnels is busted when inner and outer address
>    families are different (ipv4 vs. ipv6), this actually makes us
>    deref crap when we get it wrong.  Also from Octavian.
> 
> 8) Several automated tool discovered bug fixes from Julia Lawall.
>    Duplicate tests, incorrect NULL tests, bad size arguments to
>    kzalloc().
> 
> 9) Fix memory leak in atlx, from Jiri Slaby.
> 
> 10) Netfilter bug fixes via Patrick McHardy:
> 
>     nf_ct_ftp: update_nl_seq() does out of bounds read
>     ebtables doesn't check CAP_NET_ADMIN, oops...
>     boundary check on ipvs ioctl args, via Arjan's copy_*_user() hacks
> 
> 11) via-velocity crashes because RX descriptors are not given to
>     the chip in the correct order wrt. setting up the IRQ.
>     From Ben Hutchings.
> 
> 12) Rose protocol VC number handling fix from Bernard Pidoux.
> 
> 13) Several small e1000e bug fixes from Bruce Allan, probably the
>     most critical is the pci_{save,restore}_state() bit.
> 
> 14) NULL deref and buffer overflow fixes in hamradio and rrunner
>     from Dan Carpenter.
> 
> 15) Bad RX/TX fifo sizing in ucc_geth causes all sorts of problems,
>     fix from Dave Liu.
> 
> 16) Fix phylib deadlocks on resume and other nasties.  From
>     Anton Vorontsov.
> 
> 17) vxge tests PCI DMA mapping failures wrongly, from Denis Kirjanov.
> 
> 18) HSO driver bug fixes (endian bugs, close port state handling,
>     timeout fix for 2.x firmware, etc.) from Jan Dumon.
> 
> 19) af_packet can access SKB after dev_queue_xmit() in tpacket_snd(),
>     which is completely illegal and leads to crashes.  Fix from
>     Jarek Poplawski.
> 
> 20) Fix reported crash in sky2 TX reclaim handler when TX timeouts
>     occur, also from Jarek.  Fix verified by two users.
> 
> 21) ncmlan_cs has an extraneous closing brace in the middle of
>     nowhere, fix from Alexander Beregalov.
> 
> Please pull, thanks a lot!
> 
> The following changes since commit 066000dd856709b6980123eb39b957fe26993f7b:
>   Ananth N Mavinakayanahalli (1):
>         Revert "x86, apic: Use logical flat on intel with <= 8 logical cpus"
> 
> are available in the git repository at:
> 
>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master
> 
> Alexander Beregalov (1):
>       pcmcia: ncmlan_cs: remove odd bracket
> 
> Amit Kumar Salecha (4):
>       netxen: fix tx ring memory leak
>       netxen: fix smatch warning
>       netxen: fix set mac addr
>       netxen: update version to 4.0.72
> 
> Andrew Morton (1):
>       net/sctp/socket.c: squish warning
> 
> Anton Vorontsov (4):
>       phylib: Fix deadlock on resume
>       phylib: Properly reinitialize PHYs after hibernation
>       ucc_geth: Fix netdev watchdog triggering on suspend
>       fsl_pq_mdio: Fix iomem unmapping for non-eTSEC2.0 controllers
> 
> Arjan van de Ven (1):
>       ipvs: Add boundary check on ioctl arguments
> 
> Ben Hutchings (3):
>       via-velocity: Give RX descriptors to the NIC later on open or MTU change
>       dmfe/tulip: Let dmfe handle DM910x except for SPARC on-board chips
>       Documentation/3c509: document ethtool support
> 
> Bernard Pidoux F6BVP (1):
>       rose_loopback_timer sets VC number <= ROSE_DEFAULT_MAXVC
> 
> Bruce Allan (5):
>       e1000e: call pci_save_state() after pci_restore_state()
>       e1000e: don't accumulate PHY statistics on PHY read failure
>       e1000e: perform 10/100 adaptive IFS only on parts that support it
>       e1000e: e1000e_enable_tx_pkt_filtering() returns wrong value
>       e1000e: fix and commonize code for setting the receive address registers
> 
> Dan Carpenter (2):
>       hamradio: avoid null deref v3
>       rrunner: fix buffer overflow
> 
> Dave Liu (1):
>       ucc_geth: Fix the wrong the Rx/Tx FIFO size
> 
> David S. Miller (2):
>       cxgb3i: Fix flags test.
>       Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
> 
> Denis Kirjanov (1):
>       vxge: use pci_dma_mapping_error to test return value
> 
> Florian Fainelli (1):
>       ipvs: ip_vs_wrr.c: use lib/gcd.c
> 
> Florian Westphal (1):
>       netfilter: ebtables: enforce CAP_NET_ADMIN
> 
> Jan Dumon (6):
>       hso: Add Vendor/Product ID's for new devices
>       hso: Fix for endian issues on big endian machines
>       hso: don't change the state of a closed port
>       hso: Attempt to recover from usb bus errors
>       hso: Fix for 5 sec timeouts with v2.x firmware
>       hso: fixed missing newlines
> 
> Jarek Poplawski (2):
>       af_packet: Don't use skb after dev_queue_xmit()
>       sky2: Fix oops in sky2_xmit_frame() after TX timeout
> 
> Jiri Slaby (1):
>       NET: atlx, fix memory leak
> 
> Julia Lawall (3):
>       drivers/isdn: eliminate duplicated test
>       drivers/net/can: Correct NULL test
>       drivers/net : Correct the size argument to kzalloc
> 
> Ken Kawasaki (1):
>       pcnet_cs: add cis of KTI PE520 pcmcia network card
> 
> Mark Brown (1):
>       cs89x0: Always report failure to request interrupt
> 
> Octavian Purdila (2):
>       ip: fix mc_loop checks for tunnels with multicast outer addresses
>       tcp: update the netstamp_needed counter when cloning sockets
> 
> PJ Waskiewicz (1):
>       ixgbe: Fix compiler warning about variable being used uninitialized
> 
> Patrick McHardy (1):
>       netfilter: nf_ct_ftp: fix out of bounds read in update_nl_seq()
> 
> Rakesh Ranjan (1):
>       cxgb3i: Fix a login over vlan issue
> 
> Saeed Bishara (1):
>       mv643xx_eth: don't include cache padding in rx desc buffer size
> 
> Sriram (1):
>       TI DaVinci EMAC: Handle emac module clock correctly.
> 
> Sucheta Chakraborty (2):
>       netxen: fix ethtool register dump
>       netxen: fix ethtool link test
> 
> Ursula Braun (1):
>       claw: use "claw" as root device name
> 
> roel kluin (5):
>       usbnet: test off by one
>       atarilance: timeout ignored in lance_open()
>       niu: timeout ignored in tcam_wait_bit()
>       net: Test off by one in sh_eth_reset()
>       broadcom: Fix &&/|| confusion in bcm54xx_adjust_rxrefclk()
> 
>  Documentation/networking/3c509.txt      |   12 ++-
>  drivers/isdn/hardware/mISDN/hfcmulti.c  |    2 +-
>  drivers/net/atarilance.c                |    2 +-
>  drivers/net/atlx/atl2.c                 |    7 +-
>  drivers/net/can/mcp251x.c               |    2 +-
>  drivers/net/cs89x0.c                    |    3 +-
>  drivers/net/davinci_emac.c              |    4 +-
>  drivers/net/e1000e/82571.c              |    2 +
>  drivers/net/e1000e/es2lan.c             |    2 +
>  drivers/net/e1000e/hw.h                 |    1 +
>  drivers/net/e1000e/ich8lan.c            |    2 +
>  drivers/net/e1000e/lib.c                |   54 ++++++---
>  drivers/net/e1000e/netdev.c             |   30 +++---
>  drivers/net/fsl_pq_mdio.c               |   30 ++++-
>  drivers/net/hamradio/bpqether.c         |    4 +-
>  drivers/net/ixgbe/ixgbe_main.c          |    9 +-
>  drivers/net/ll_temac_main.c             |    2 +-
>  drivers/net/mv643xx_eth.c               |    6 +-
>  drivers/net/netxen/netxen_nic.h         |    4 +-
>  drivers/net/netxen/netxen_nic_ethtool.c |  195 +++++++++++--------------------
>  drivers/net/netxen/netxen_nic_hw.c      |    6 +-
>  drivers/net/netxen/netxen_nic_init.c    |    4 +-
>  drivers/net/netxen/netxen_nic_main.c    |   10 +-
>  drivers/net/niu.c                       |    2 +-
>  drivers/net/pcmcia/nmclan_cs.c          |    1 -
>  drivers/net/pcmcia/pcnet_cs.c           |    4 +-
>  drivers/net/phy/broadcom.c              |    4 +-
>  drivers/net/phy/mdio_bus.c              |   72 ++++++++++--
>  drivers/net/phy/phy_device.c            |   30 +++---
>  drivers/net/rrunner.c                   |    2 +-
>  drivers/net/sh_eth.c                    |    2 +-
>  drivers/net/sky2.c                      |    3 +-
>  drivers/net/tulip/Kconfig               |    4 +
>  drivers/net/tulip/dmfe.c                |   21 ++++
>  drivers/net/tulip/tulip_core.c          |   32 ++++-
>  drivers/net/ucc_geth.c                  |    3 +-
>  drivers/net/ucc_geth.h                  |   13 +-
>  drivers/net/usb/hso.c                   |  105 ++++++++++++-----
>  drivers/net/usb/rtl8150.c               |    4 +-
>  drivers/net/via-velocity.c              |    8 +-
>  drivers/net/vxge/vxge-main.c            |    2 +-
>  drivers/s390/net/claw.c                 |    2 +-
>  drivers/scsi/cxgb3i/cxgb3i_offload.c    |   34 +++++-
>  drivers/serial/serial_cs.c              |   15 +++-
>  firmware/Makefile                       |    3 +-
>  firmware/WHENCE                         |    1 +
>  firmware/cis/PE520.cis.ihex             |    9 ++
>  include/linux/phy.h                     |    1 +
>  include/net/ip.h                        |   16 +++
>  net/bridge/netfilter/ebtables.c         |    6 +
>  net/core/sock.c                         |    4 +
>  net/ipv4/ip_output.c                    |    2 +-
>  net/ipv6/ip6_output.c                   |    3 +-
>  net/netfilter/ipvs/Kconfig              |    3 +-
>  net/netfilter/ipvs/ip_vs_ctl.c          |   14 ++-
>  net/netfilter/ipvs/ip_vs_wrr.c          |   15 +---
>  net/netfilter/nf_conntrack_ftp.c        |   18 ++--
>  net/packet/af_packet.c                  |   19 +++-
>  net/rose/rose_loopback.c                |    2 +-
>  net/sctp/socket.c                       |    3 +-
>  60 files changed, 560 insertions(+), 315 deletions(-)
>  create mode 100644 firmware/cis/PE520.cis.ihex
