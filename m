From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH 0/6] atm: propagate atm_dev signal
 carrier to LOWER_UP of netdevice
Date: Sat, 3 Jul 2010 16:09:20 -0400
Message-ID: <20100703160920.13bb0540@thirdoffive.cmf.nrl.navy.mil>
References: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:59629 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593Ab0GCUJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 16:09:57 -0400
In-Reply-To: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks for writing this.  this is something that has been missing for
some time in the atm stack.  however, i was hoping it could take a
different approach.  i would prefer this mechanism to be more generic
instead of being only suitable for signalling carrier changes.   take a
look at the notifier/register_netdevice_notifier scheme.

clients (like br2684) who wish to get these notifications, would need
to call register_atmdevice_notifier().  and yes, instead of handling
setting the signal flag yourself, everyone (including the drivers in
usb/atm) should be using the atm_dev_signal_change().

i am not fond of the idea of adding to the vcc struct something that
is really per device, not per vcc.

On Fri,  2 Jul 2010 19:47:04 +0200
Karl Hiramoto <karl@hiramoto.org> wrote:

> In userspace it's helpfull to know if a network device has a carrier
> signal. Often it is monitored via netlink.  This patchset allows a
> way for the struct atm_dev drivers to pass carrier on/off to the
> netdevice.
> 
> For DSL, carrier is on when the line has reached showtime state.
> 
> Currently this patchset only propagates the changes to br2684 vccs,
> as this is the only type of hardware I have to test.
> 
> If you prefer git you can pull from:
> git://github.com/karlhiramoto/linux-2.6.git linux-atm
> 
> Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
> 
> Karl Hiramoto (6):
>   atm: add hooks to propagate signal changes to netdevice
>   atm br2684: add callback for carrier signal changes.
>   atm/idt77105.c: call atm_dev_signal_change() when signal changes.
>   atm/solos-pci: call atm_dev_signal_change() when signal changes.
>   atm/suni.c: call atm_dev_signal_change() when signal changes.
>   atm/adummy: add syfs DEVICE_ATTR to change signal
> 
>  drivers/atm/adummy.c    |   39
> +++++++++++++++++++++++++++++++++++++++ drivers/atm/idt77105.c  |
> 11 ++++++----- drivers/atm/solos-pci.c |    6 +++---
>  drivers/atm/suni.c      |    5 +++--
>  include/linux/atmdev.h  |    5 +++++
>  net/atm/br2684.c        |   13 +++++++++++++
>  net/atm/common.c        |   33 +++++++++++++++++++++++++++++++++
>  7 files changed, 102 insertions(+), 10 deletions(-)
> 
> 
> ------------------------------------------------------------------------------
> This SF.net email is sponsored by Sprint
> What will you do first with EVO, the first 4G phone?
> Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
> _______________________________________________
> Linux-atm-general mailing list
> Linux-atm-general@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/linux-atm-general
> 

