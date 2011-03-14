From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 22:17:40 +0000
Message-ID: <1300141060.32696.36.camel@localhost.localdomain>
References: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
	 <1300128035.2584.6.camel@bwh-desktop>
	 <1300131040.32696.23.camel@localhost.localdomain>
	 <20110314.132355.226777213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:8575 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab1CNWSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 18:18:44 -0400
In-Reply-To: <20110314.132355.226777213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-14 at 20:23 +0000, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Date: Mon, 14 Mar 2011 19:30:40 +0000
> 
> > On Mon, 2011-03-14 at 18:40 +0000, Ben Hutchings wrote:
> >> I know you have asked for this to be pulled, in order to retain its
> >> history, but I'm not sure that David Miller will do this unless the
> >> driver is at least buildable at each stage in the history.  (However,
> >> given that the driver wouldn't be enabled before it's added, I'm not
> >> sure it matters in this case.)
> > 
> > I think it should be, at least from the second commit onwards (modulo
> > any mistakes made in the past).
> 
> I don't want to retain all of that history, there are so many broken
> points in the history that the only thing you can do is go back and
> add Kconfig commits to depend the driver upon BROKEN, and that in effect
> changes the history devalueing it even further.
> 
> I just want one patch that adds the driver in it's most current state,
> and that's all.

Would you consider a commit patch which imports the baseline driver as
is from xen.git (this builds and is functional but needed clean up)
followed by the cleanup series? I made sure the cleanup part builds and
works at each step as I went (but I will run through it again to be
sure).

There is real value (to me at least) in keeping the cleanup separate and
being able to (even manually) associate the first upstream commit with
an equivalent point in the historical code.

IOW 1952b4d9e6c8..072407c789a0 collapse to a single commit followed by
(s/0724.../$COLLAPSED COMMIT ID/):

The following changes since commit 072407c789a0cdc6b8adba49d5bbfac5d5feb9d3:
  Ian Campbell (1):
        xen: netback: handle incoming GSO SKBs which are not CHECKSUM_PARTIAL

are available in the git repository at:

  git://xenbits.xen.org/people/ianc/linux-2.6.git upstream/dom0/backend/netback

Ian Campbell (38):
      xen: netback: rationalise types used in count_skb_slots
      xen: netback: refactor logic for moving to a new receive buffer.
      xen: netback: refactor code to get next rx buffer into own function.
      xen: netback: simplify use of netbk_add_frag_responses
      xen: netback: cleanup coding style
      xen: netback: drop private ?PRINTK macros in favour of pr_*
      xen: netback: move under drivers/net/xen-netback/
      xen: netback: remove queue_length module option
      xen: netback: correct error return from ethtool hooks.
      xen: netback: avoid leading _ in function parameter names.
      xen: netback: drop unused debug interrupt handler.
      xen: netif: properly namespace the Xen netif protocol header.
      xen: netif: improve Kconfig help text for front- and backend drivers.
      xen: netback: drop ethtool drvinfo callback
      xen: netback: use xen_netbk prefix where appropriate
      xen: netback: refactor to make all xen_netbk knowledge internal to netback.c
      xen: netback: use xenvif_ prefix where appropriate
      xen: netback: add reference from xenvif to xen_netbk
      xen: netback: refactor to separate network device from worker pools
      xen: netback: switch to kthread mode and drop tasklet mode
      xen: netback: handle frames whose head crosses a page boundary
      xen: netback: return correct values from start_xmit
      xen: netback: remove useless memset to zero.
      xen: netback: use register_netdev()
      xen: netback: simplify unwinding netback_init's work on failure.
      xen: netback: use core network carrier flag.
      xen: netback: s/xenvif_queue_full/xenvif_rx_queue_full/
      xen: netback: add xenvif_rx_schedulable
      xen: netback: further separate xen_netbk and xenvif
      xen: netback: use netdev_LEVEL instead of pr_LEVEL
      xen: netback: drop rx_notify and notify_list array in favour of a normal list
      xen: netback: Make dependency on PageForeign conditional
      xen: netback: completely drop foreign page support
      xen: netback: ethtool stats fields should be unsigned long
      xen: netback: do not update last_rx on receive.
      xen: netback: Allow headroom for VLAN header in SG MTU calculation.
      xen: netback: use stats from struct net_device
      xen: netback: netdevice features should be u32

 drivers/net/Kconfig                               |   38 +-
 drivers/net/Makefile                              |    1 +
 drivers/{xen/netback => net/xen-netback}/Makefile |    0 
 drivers/net/xen-netback/common.h                  |  161 ++
 drivers/net/xen-netback/interface.c               |  424 +++++
 drivers/net/xen-netback/netback.c                 | 1745 +++++++++++++++++++
 drivers/{xen/netback => net/xen-netback}/xenbus.c |  155 +-
 drivers/net/xen-netfront.c                        |   20 +-
 drivers/xen/Kconfig                               |    7 -
 drivers/xen/Makefile                              |    1 -
 drivers/xen/netback/common.h                      |  326 ----
 drivers/xen/netback/interface.c                   |  471 -----
 drivers/xen/netback/netback.c                     | 1902 ---------------------
 include/xen/interface/io/netif.h                  |   80 +-
 14 files changed, 2483 insertions(+), 2848 deletions(-)
 rename drivers/{xen/netback => net/xen-netback}/Makefile (100%)
 create mode 100644 drivers/net/xen-netback/common.h
 create mode 100644 drivers/net/xen-netback/interface.c
 create mode 100644 drivers/net/xen-netback/netback.c
 rename drivers/{xen/netback => net/xen-netback}/xenbus.c (75%)
 delete mode 100644 drivers/xen/netback/common.h
 delete mode 100644 drivers/xen/netback/interface.c
 delete mode 100644 drivers/xen/netback/netback.c


