From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v3 linux-next] et131x: Promote staging et131x driver
 to drivers/net
Date: Wed, 23 Jan 2013 06:32:16 -0800
Message-ID: <20130123143216.GA2050@kroah.com>
References: <1358935859-29525-1-git-send-email-mark.einon@gmail.com>
 <1358945130-3101-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sfr@canb.auug.org.au,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com
To: Mark Einon <mark.einon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358945130-3101-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 23, 2013 at 12:45:30PM +0000, Mark Einon wrote:
> This patch moves the et131x gigabit ethernet driver from drivers/staging
> to drivers/net/ethernet/agere.
> 
> All the existing issues noted for this driver have been resolved, apart
> from one performance issue where some fragmented packets suffer from
> frame receive errors.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
> ---
> 
> Changes from V2 - vendor name changed from Atheros to Agere in drivers/net/ethernet/agere/Kconfig
> 
>  MAINTAINERS                                        |   11 ++++---
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/ethernet/agere/Kconfig                 |   32 ++++++++++++++++++++
>  .../et131x => net/ethernet/agere}/Makefile         |    1 +
>  .../et131x => net/ethernet/agere}/et131x.c         |    0
>  .../et131x => net/ethernet/agere}/et131x.h         |    0
>  drivers/staging/Kconfig                            |    2 --
>  drivers/staging/Makefile                           |    1 -
>  drivers/staging/et131x/Kconfig                     |   10 ------
>  drivers/staging/et131x/README                      |   16 ----------
>  11 files changed, 41 insertions(+), 34 deletions(-)
>  create mode 100644 drivers/net/ethernet/agere/Kconfig
>  rename drivers/{staging/et131x => net/ethernet/agere}/Makefile (98%)
>  rename drivers/{staging/et131x => net/ethernet/agere}/et131x.c (100%)
>  rename drivers/{staging/et131x => net/ethernet/agere}/et131x.h (100%)
>  delete mode 100644 drivers/staging/et131x/Kconfig
>  delete mode 100644 drivers/staging/et131x/README

Creating a patch this way is the correct way to do it, however it gives
no clue to the network developers as to exactly what is in this driver
at the moment :(

I usually recommend just creating a new patch, that adds the driver to
the proper place in the kernel, and sending that in.  If the subsystem
maintainers accept it, then I can just delete the staging driver.

Yes, this looses the history of the code, but usually no one cares about
that for staging drivers.

If that's not ok, I have no problem accepting this, if I get an ack from
the subsystem maintainers that it's ok, but again, this patch makes it
pretty hard for them to know that or not.

thanks,

greg k-h
