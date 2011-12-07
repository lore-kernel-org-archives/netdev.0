From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Tue, 06 Dec 2011 22:01:40 -0800
Message-ID: <1323237700.1762.24.camel@joe2Laptop>
References: <4EDED071.40900@linux.vnet.ibm.com>
	 <1323229439.2415.23.camel@jtkirshe-mobl>
	 <1323231268.1762.19.camel@joe2Laptop> <4EDEF05F.4020901@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36996 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751054Ab1LGGBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 01:01:42 -0500
In-Reply-To: <4EDEF05F.4020901@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-07 at 12:49 +0800, Michael Wang wrote:
> On 12/07/2011 12:14 PM, Joe Perches wrote:
> 
> > On Tue, 2011-12-06 at 19:43 -0800, Jeff Kirsher wrote:
> >> On Tue, 2011-12-06 at 18:33 -0800, Michael Wang wrote:
> >>> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> >>> Use true and false instead of 1 and 0 when assign value to a bool type
> >>> variable.
> >> Thanks Michael, I have added your patch to my queue of e1000e patches.
> > 
> > There are more of these uses in intel drivers.
> > 
> > Perhaps you could run this cocci/spatch
> > on drivers/net/ethernet/intel/...
> > 
> > $ cat bool.cocci
> > @@
> > bool b;
> > @@
> > 
> > -b = 0;
> > +b = false;
> > 
> > @@
> > bool b;
> > @@
> > 
> > -b = 1;
> > +b = true;
> > 
> > $ git ls-files drivers/net/ethernet/intel/ | grep "\.c$" | while read file ; do spatch -in_place -sp_file bool.cocci $file ; done
> > 
> > 
> 
> Hi, Joe
> 
> I think there are lots of such cases in kernel, and I think it is a
> legacy issue with some story in it.

Actually, there are relatively few bool = 0|1; uses.

> The reason I only change the e1000e is that the patch I send before will
> broken the style of e1000e, because it's using true and false, not 1 and 0.

Scriptable fixes are easy.

> I think this will be a huge work if we want to correct all these cases,

Perhaps you're thinking of int uses that could be
converted to bool? There are a lot of those.

This is the diffstat I get for drivers/net/ethernet
for the current uses of bool foo = 0|1;

$ git diff --stat drivers/net
 drivers/net/ethernet/broadcom/tg3.c           |    8 ++++----
 drivers/net/ethernet/brocade/bna/bnad.c       |    4 ++--
 drivers/net/ethernet/dec/tulip/de4x5.c        |    4 ++--
 drivers/net/ethernet/intel/e1000/e1000_main.c |   10 +++++-----
 drivers/net/ethernet/intel/e1000e/netdev.c    |   16 ++++++++--------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c   |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |    4 ++--
 drivers/net/ethernet/sfc/falcon.c             |    2 +-
 drivers/net/ethernet/sfc/mtd.c                |    6 +++---
 drivers/net/ethernet/tile/tilepro.c           |    4 ++--
 drivers/net/ethernet/xilinx/xilinx_emaclite.c |    4 ++--
 12 files changed, 33 insertions(+), 33 deletions(-)

> and I think the good way is to separate the work to small pieces and
> finish them slowly.

I think that's true for the int->bool conversions.
