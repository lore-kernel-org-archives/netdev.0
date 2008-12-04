From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ATM 32-bit ioctl compatibility
Date: Wed, 03 Dec 2008 22:12:54 -0800 (PST)
Message-ID: <20081203.221254.112572542.davem@davemloft.net>
References: <1228320031.7381.4.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750938AbYLDGMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 01:12:54 -0500
In-Reply-To: <1228320031.7381.4.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 03 Dec 2008 16:00:31 +0000

> We lack compat ioctl support through most of the ATM code. This patch
> deals with most of it, and I can now at least use BR2684 and PPPoATM
> with 32-bit userspace.
> 
> I haven't added a .compat_ioctl method to struct atm_ioctl, because
> AFAICT none of the current users need any conversion -- so we can just
> call the ->ioctl() method in every case. I looked at br2684, clip, lec,
> mpc, pppoatm and atmtcp.
> 
> In svc_compat_ioctl() the only mangling which is needed is to change
> COMPAT_ATM_ADDPARTY to ATM_ADDPARTY. Although it's defined as
> 	_IOW('a', ATMIOC_SPECIAL+4,struct atm_iobuf)
> it doesn't actually _take_ a struct atm_iobuf as an argument -- it takes
> a struct sockaddr_atmsvc, which _is_ the same between 32-bit and 64-bit
> code, so doesn't need conversion.
> 
> Almost all of vcc_ioctl() would have been identical, so I converted that
> into a core do_vcc_ioctl() function with an 'int compat' argument.
> 
> I've done the same with atm_dev_ioctl(), where there _are_ a few
> differences, but still it's relatively contained and there would
> otherwise have been a lot of duplication.
> 
> I haven't done any of the actual device-specific ioctls, although I've
> added a compat_ioctl method to struct atmdev_ops.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Looks good David, applied to net-next-2.6, thanks!
