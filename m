From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 11:40:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801154021.GA7696@gtf.org>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 01, 2003 at 04:02:32PM +0100, Matthew Wilcox wrote:
> and here's the diffstat
> 
>  drivers/net/8139too.c     |  330 ++++++++--------------
>  drivers/net/tg3.c         |  584 ++++++++++++++++------------------------
>  include/linux/ethtool.h   |  100 ++++++
>  include/linux/netdevice.h |    5 
>  net/core/Makefile         |    4 
>  net/core/dev.c            |   16 -
>  net/core/ethtool.c        |  671 ++++++++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 1154 insertions(+), 556 deletions(-)

Comments:

* need SET_ETHTOOL_OPS macro or HAVE_ETHTOOL_OPS test macro or similar

* I still do not see the need to change a simple storage of a constant
  (into ethtool_gdrvinfo) into _four_ separate function call hooks (reg
  dump len, eeprom dump len, nic-specific stats len, self-test len).
  Internal kernel code that needs this information is always a slow path
  anyway, so just call the ->get_drvinfo hook internally.

* I prefer not to add '#include <linux/types.h>' to ethtool.h

Other than those, looks real good.

	Jeff
