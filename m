From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net-next:master 209/235] drivers/net/usb/smsc95xx.c:1134:39-50:
 ERROR: reference preceded by free on line 1136
Date: Thu, 8 Nov 2012 20:40:24 +0800
Message-ID: <20121108124024.GA9627@localhost>
References: <509b644e.GcrhQalfrxVfFLjF%yuanhan.liu@linux.intel.com>
 <alpine.DEB.2.02.1211080907340.1945@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>,
	changlongx.xie@intel.com,
	Steve Glendinning <steve.glendinning@smsc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1211080907340.1945@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia,

On Thu, Nov 08, 2012 at 09:08:04AM +0100, Julia Lawall wrote:
> It's a false positive because check_warn_return does a return.

Right.

> But I wonder if there is a way that we can encourage people not to
> do things like that?

Well I suspect the memory leak bug 06a221be0 tries to fix might be
due to check_warn_return() hiding the otherwise very obvious syntax
highlighted 'return' statement.

Thanks,
Fengguang

> >TO: Ming Lei <ming.lei@canonical.com>
> >CC: netdev@vger.kernel.org
> >
> >
> >Hi Ming,
> >
> >FYI, there are coccinelle warnings in
> >
> >tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> >head:   f1e0b5b4f1eae56a3192688177f36e2bdf0e01ac
> >commit: 06a221be022c2cc98a48e0808a4ef0dc8f0b3a34 [209/235] usbnet: smsc95xx: fix memory leak in smsc95xx_suspend
> >:::::: branch date: 8 hours ago
> >:::::: commit date: 23 hours ago
> >
> >+ drivers/net/usb/smsc95xx.c:1134:39-50: ERROR: reference preceded by free on line 1136
> > drivers/net/usb/smsc95xx.c:1139:8-19: ERROR: reference preceded by free on line 1136
> >
> >git remote update net-next
> >git checkout 06a221be022c2cc98a48e0808a4ef0dc8f0b3a34
> >vim +1134 drivers/net/usb/smsc95xx.c
> >
> >bbd9f9ee Steve Glendinning 2012-10-26  1128  			offset[filter/4] |= 0x00 << ((filter % 4) * 8);
> >bbd9f9ee Steve Glendinning 2012-10-26  1129  			crc[filter/2] |= smsc_crc(dev->net->dev_addr, ETH_ALEN, filter);
> >bbd9f9ee Steve Glendinning 2012-10-26  1130  			filter++;
> >bbd9f9ee Steve Glendinning 2012-10-26  1131  		}
> >bbd9f9ee Steve Glendinning 2012-10-26  1132
> >bbd9f9ee Steve Glendinning 2012-10-26  1133  		for (i = 0; i < (pdata->wuff_filter_count * 4); i++) {
> >bbd9f9ee Steve Glendinning 2012-10-26 @1134  			ret = smsc95xx_write_reg(dev, WUFF, filter_mask[i]);
> >06a221be Ming Lei          2012-11-06  1135  			if (ret < 0)
> >06a221be Ming Lei          2012-11-06 @1136  				kfree(filter_mask);
> >bbd9f9ee Steve Glendinning 2012-10-26  1137  			check_warn_return(ret, "Error writing WUFF");
> >bbd9f9ee Steve Glendinning 2012-10-26  1138  		}
> >06a221be Ming Lei          2012-11-06  1139  		kfree(filter_mask);
> >
> >:::::: The code at line 1134 was first introduced by commit:
> >:::::: bbd9f9e smsc95xx: add wol support for more frame types
> >
> >:::::: TO: Steve Glendinning <steve.glendinning@shawell.net>
> >:::::: CC: David S. Miller <davem@davemloft.net>
> >
> >---
> >0-DAY kernel build testing backend         Open Source Technology Center
> >Fengguang Wu, Yuanhan Liu                              Intel Corporation
> >
