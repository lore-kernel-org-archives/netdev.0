From: Dan Aloni <da-x@monatomic.org>
Subject: Re: [PATCH] Fix race condition about network device name allocation
Date: Thu, 14 Jun 2007 09:07:38 +0300
Message-ID: <20070614060738.GA10095@localdomain>
References: <1178862045.3979.33.camel@kane-linux> <20070511092519.1f34ab34@freepuppy> <1179130660.3881.23.camel@kane-linux> <20070514085840.17a343f7@freepuppy> <20070613094521.GA8860@localdomain> <20070613093631.42a45916@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from noname.neutralserver.com ([70.84.186.210]:39613 "EHLO
	noname.neutralserver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbXFNGHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 02:07:43 -0400
Content-Disposition: inline
In-Reply-To: <20070613093631.42a45916@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 09:36:31AM -0700, Stephen Hemminger wrote:
> On Wed, 13 Jun 2007 12:45:21 +0300
> Dan Aloni <da-x@monatomic.org> wrote:
> 
> > On Mon, May 14, 2007 at 08:58:40AM -0700, Stephen Hemminger wrote:
> > > Kenji Kaneshige found this race between device removal and
> > > registration.  On unregister it is possible for the old device to
> > > exist, because sysfs file is still open.  A new device with 'eth%d'
> > > will select the same name, but sysfs kobject register will fial.
> > > 
> > > The following changes the shutdown order slightly. It hold a removes the sysfs
> > > entries earlier (on unregister_netdevice), but holds a kobject reference.
> > > Then when todo runs the actual last put free happens.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > That patch breaks the bonding driver. After reverting it I avoid this crash:
> > 
>[..]
> > 
> 
> I assume this happens when bonded slave device is removed?

Yes, it's just a simple removal via sysfs.

> Which kernel version?

2.6.21.5

-- 
Dan Aloni
XIV LTD, http://www.xivstorage.com
da-x (at) monatomic.org, dan (at) xiv.co.il
