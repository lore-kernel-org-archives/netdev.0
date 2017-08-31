From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] net: cpsw: Don't handle SIOC[GS]HWTSTAMP when
 CPTS is disabled
Date: Thu, 31 Aug 2017 09:48:07 +0200
Message-ID: <20170831074807.3dbbt6qhqxdquipa@localhost>
References: <20170830065055.419-1-stefan.sorensen@spectralink.com>
 <20170830.144745.947488279115809130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan.sorensen@spectralink.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35068 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdHaHsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 03:48:12 -0400
Content-Disposition: inline
In-Reply-To: <20170830.144745.947488279115809130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 02:47:45PM -0700, David Miller wrote:
> It should not be required to disable a Kconfig option just to get PHY
> timestamping to work properly.

Well, if the MAC driver handles the ioctl and enables time stamping,
then the PHY driver's time stamping remains disabled.  We don't have a
way to choose PHY time stamping at run time.
 
> Rather, if the CPTS code returns -EOPNOTSUPP we should try to
> fallthrough to the PHY library based methods.

I agree that it would be better for the core (rather than the
individual drivers) to handle this case.

There are a few callers of .ndo_do_ioctl to consider.  Besides
dev_ifsioc() there is at least vlan_dev_ioctl() that needs to handle
the EOPNOTSUPP.

Thanks,
Richard
