From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2011-11-22 #2
Date: Tue, 22 Nov 2011 17:41:08 -0500
Message-ID: <20111122224108.GJ8452@tuxdriver.com>
References: <20111122193505.GC8452@tuxdriver.com>
 <20111122215611.GI8452@tuxdriver.com>
 <20111122.173729.1155753802137219940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43299 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334Ab1KVWp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 17:45:28 -0500
Content-Disposition: inline
In-Reply-To: <20111122.173729.1155753802137219940.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2011 at 05:37:29PM -0500, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Tue, 22 Nov 2011 16:56:12 -0500
> 
> > Here is the latest batch of fixes intended for 3.2.  This includes a
> > correction for a user-visible error in mac80211's debugfs info, a fix
> > for a potential memory corrupter in prism54, an endian fix for rt2x00,
> > an endian fix for mac80211, a fix for a NULL derefernce in cfg80211, a
> > locking fix for p54spi and a deadlock fix also for p54spi.
> > 
> > This reverts the problematic rt2x00 patches from the earlier pull
> > request.
> > 
> > Please let me know if there are problems!
> 
> I'm still seeing the problematic rt2x00 changes when I pull:
> 
> [davem@boricha net]$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem
> remote: Counting objects: 112, done.        
> remote: Compressing objects: 100% (82/82), done.        
> remote: Total 82 (delta 71), reused 0 (delta 0)        
> Unpacking objects: 100% (82/82), done.
> From git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless
>  * branch            for-davem  -> FETCH_HEAD
> Updating 5eccdf5..02f1ce3
> Fast-forward
>  drivers/net/wireless/p54/p54spi.c        |    5 +++--
>  drivers/net/wireless/prism54/isl_ioctl.c |    2 +-
>  drivers/net/wireless/rt2x00/rt2800lib.c  |    2 +-
>  net/mac80211/debugfs_sta.c               |    4 ++--
>  net/mac80211/status.c                    |    8 ++++----
>  net/wireless/reg.c                       |    4 ++++
>  6 files changed, 15 insertions(+), 10 deletions(-)
> [davem@boricha net]$ git format-patch ORIG_HEAD
> 0001-rt2800pci-handle-spurious-interrupts.patch
> 0002-rt2x00-handle-spurious-pci-interrupts.patch

They're here...

> 0003-rt2x00-Fix-efuse-EEPROM-reading-on-PPC32.patch
> 0004-p54spi-Add-missing-spin_lock_init.patch
> 0005-p54spi-Fix-workqueue-deadlock.patch
> 0006-mac80211-Fix-AMSDU-rate-printout-in-debugfs.patch
> 0007-mac80211-Fix-endian-bug-in-radiotap-header-generatio.patch
> 0008-cfg80211-fix-regulatory-NULL-dereference.patch
> 0009-prism54-potential-memory-corruption-in-prism54_get_e.patch
> 0010-Revert-rt2x00-handle-spurious-pci-interrupts.patch
> 0011-Revert-rt2800pci-handle-spurious-interrupts.patch

And I revert them here.

Linus always says to live with our mistakes?  I was trying to avoid
a rebase both for my own pain and that of my downstream maintainers.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
