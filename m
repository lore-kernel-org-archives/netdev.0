From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] net: xen-netback: include linux/vmalloc.h again
Date: Thu, 12 Jun 2014 10:07:45 +0100
Message-ID: <20140612090745.GV11959@zion.uk.xensource.com>
References: <5508988.K5Wec8A6hA@wuerfel>
 <20140610084454.GB28084@zion.uk.xensource.com>
 <20140611.151901.986995853392690449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <wei.liu2@citrix.com>, <arnd@arndb.de>, <netdev@vger.kernel.org>,
	<andrew.bennieston@citrix.com>, <xen-devel@lists.xenproject.org>,
	<jwboyer@fedoraproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27847 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932728AbaFLJHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 05:07:48 -0400
Content-Disposition: inline
In-Reply-To: <20140611.151901.986995853392690449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2014 at 03:19:01PM -0700, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Tue, 10 Jun 2014 09:44:54 +0100
> 
> > On Tue, Jun 10, 2014 at 10:34:36AM +0200, Arnd Bergmann wrote:
> >> commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into
> >> queue struct") added a use of vzalloc/vfree to interface.c, but
> >> removed the #include <linux/vmalloc.h> statement at the same time,
> >> which causes this build error:
> >> 
> >> drivers/net/xen-netback/interface.c: In function 'xenvif_free':
> >> drivers/net/xen-netback/interface.c:754:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
> >>   vfree(vif->queues);
> >>   ^
> >> cc1: some warnings being treated as errors
> >> 
> >> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> >> Cc: Wei Liu <wei.liu2@citrix.com>
> >> Cc: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> > 
> > Acked-by: Wei Liu <wei.liu2@citrix.com>
> > 
> > This didn't happen to me when I built it on x86 though. Just curious,
> > did you build it on othet platform, say, ARM?
> 
> ARM and PowerPC will both show this problem.
> 
> The issue is that x86 get's linux/vmalloc.h implicitly through one of
> it's asm/ headers, thus you'll never hit the issue if you only build
> test on that arch.

Good to know. I shall keep an eye on this in the future.

Thanks
Wei.
