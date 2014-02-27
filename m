From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH 0/4] Provide netdev naming-policy via sysfs
Date: Thu, 27 Feb 2014 16:47:51 +0100
Message-ID: <CAG-2HqWahCVvDLPwoMo7O4kam+W0o7BQGm4cRBvc9=X_p0fF7Q@mail.gmail.com>
References: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes berg <johannes@sipsolutions.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:33763 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbaB0PsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 10:48:13 -0500
Received: by mail-ee0-f44.google.com with SMTP id d49so1541790eek.3
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 07:48:12 -0800 (PST)
In-Reply-To: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 3:47 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> This series implements a new sysfs attribute for netdevs called
> "name_assign_type". It provides an integer that describes where an interface
> name comes from. See Patch #1 for a description of this attribute. It is
> modelled after the existing "addr_assign_type" attribute.
>
> The main use-case is to allow udev to skip applying reliable ifnames to virtual
> devices. For instance, if wifi-P2P devices are created, wpas already provides a
> suitable naming-policy and udev shouldn't touch these devices. Same is true for
> other virtual devices.
> The idea is that if a device-name was provided by user-space, we should always
> prefer fixing this naming-policy instead of making udev rename the device. For
> kernel provided names that's hardly possible, though. Providing the
> naming-policy source via sysfs is thus a simple way to see whether renames are
> needed.
>
> Additionally, this field allows to detect whether a netdev has been manually
> renamed, which is quite useful for debugging and during crash-recovery.

Moreover, it would be useful for udev to reliably know if some other
userspace process already renamed a device, so we know not to touch
it. This can easily happen for instance if some renaming happens in
the initrd or from script called from udev rules.

Acked-by: Tom Gundersen <teg@jklm.no>

> David Herrmann (4):
>   net: add name_assign_type netdev attribute
>   mac80211: set NET_NAME_USER for user-space created ifs
>   ath6kl: set NET_NAME_USER for P2P ifs
>   brcmfmac: set NET_NAME_USER for P2P ifs
>
>  drivers/net/wireless/ath/ath6kl/cfg80211.c    | 5 ++++-
>  drivers/net/wireless/ath/ath6kl/cfg80211.h    | 1 +
>  drivers/net/wireless/ath/ath6kl/core.c        | 4 ++--
>  drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 1 +
>  include/linux/netdevice.h                     | 6 ++++++
>  net/core/dev.c                                | 7 +++++++
>  net/core/net-sysfs.c                          | 2 ++
>  net/core/rtnetlink.c                          | 2 ++
>  net/mac80211/iface.c                          | 1 +
>  9 files changed, 26 insertions(+), 3 deletions(-)
>
> --
> 1.9.0
>
