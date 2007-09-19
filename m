From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Please pull 'iwlwifi' branch of wireless-2.6
Date: Wed, 19 Sep 2007 11:13:26 +0100
Message-ID: <20070919101326.GA32432@infradead.org>
References: <20070918185040.GF4940@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38912 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140AbXISKOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 06:14:10 -0400
Content-Disposition: inline
In-Reply-To: <20070918185040.GF4940@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2007 at 02:50:40PM -0400, John W. Linville wrote:
> Jeff & Dave,
> 
> Here it is -- it's big, it's...well...beautiful in its own way...well,
> at least it seems to work... :-)
> 
> There are some outstanding issues.  The driver does more than it
> probably should under the covers instead of in the stack, and the
> issue of including headers with a "../../mac80211/..." path remains.
> Still, I think it would be better to get this mainlined than to keep
> it out of stream.

it really needs to be moved into a directory of it's own.
The useless per-file CFLAGS need to go most places can trivially
be made unconditional anyway.

The depends on m for CONFIG_IWL4965 and CONFIG_IWL3945 needs to go,
we don't put drivers int that need to be modular.

This is just a tiny review from the build system point of view.
> 
> Thanks!
> 
> John
> 
> ---
> 
> Patch available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/iwlwifi/0001-iwlwifi-add-iwlwifi-wireless-drivers.patch
> 
> ---
> 
> The following changes since commit 0d4cbb5e7f60b2f1a4d8b7f6ea4cc264262c7a01:
>   Linus Torvalds (1):
>         Linux 2.6.23-rc6
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git iwlwifi
> 
> Zhu Yi (1):
>       iwlwifi: add iwlwifi wireless drivers
> 
>  MAINTAINERS                         |    9 +
>  drivers/net/wireless/Kconfig        |  129 +
>  drivers/net/wireless/Makefile       |   12 +
>  drivers/net/wireless/iwl-3945-hw.h  |  118 +
>  drivers/net/wireless/iwl-3945-rs.c  |  979 ++++
>  drivers/net/wireless/iwl-3945-rs.h  |  191 +
>  drivers/net/wireless/iwl-3945.c     | 2290 +++++++++
>  drivers/net/wireless/iwl-3945.h     |   41 +
>  drivers/net/wireless/iwl-4965-hw.h  |  581 +++
>  drivers/net/wireless/iwl-4965-rs.c  | 2118 ++++++++
>  drivers/net/wireless/iwl-4965-rs.h  |  266 +
>  drivers/net/wireless/iwl-4965.c     | 4719 ++++++++++++++++++
>  drivers/net/wireless/iwl-4965.h     |  341 ++
>  drivers/net/wireless/iwl-channel.h  |  161 +
>  drivers/net/wireless/iwl-commands.h | 1734 +++++++
>  drivers/net/wireless/iwl-debug.h    |  149 +
>  drivers/net/wireless/iwl-eeprom.h   |  336 ++
>  drivers/net/wireless/iwl-helpers.h  |  255 +
>  drivers/net/wireless/iwl-hw.h       |  537 ++
>  drivers/net/wireless/iwl-io.h       |  470 ++
>  drivers/net/wireless/iwl-priv.h     |  308 ++
>  drivers/net/wireless/iwl-prph.h     |  229 +
>  drivers/net/wireless/iwl-spectrum.h |   91 +
>  drivers/net/wireless/iwl3945-base.c | 8732 ++++++++++++++++++++++++++++++++
>  drivers/net/wireless/iwl4965-base.c | 9323 +++++++++++++++++++++++++++++++++++
>  drivers/net/wireless/iwlwifi.h      |  713 +++
>  26 files changed, 34832 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/wireless/iwl-3945-hw.h
>  create mode 100644 drivers/net/wireless/iwl-3945-rs.c
>  create mode 100644 drivers/net/wireless/iwl-3945-rs.h
>  create mode 100644 drivers/net/wireless/iwl-3945.c
>  create mode 100644 drivers/net/wireless/iwl-3945.h
>  create mode 100644 drivers/net/wireless/iwl-4965-hw.h
>  create mode 100644 drivers/net/wireless/iwl-4965-rs.c
>  create mode 100644 drivers/net/wireless/iwl-4965-rs.h
>  create mode 100644 drivers/net/wireless/iwl-4965.c
>  create mode 100644 drivers/net/wireless/iwl-4965.h
>  create mode 100644 drivers/net/wireless/iwl-channel.h
>  create mode 100644 drivers/net/wireless/iwl-commands.h
>  create mode 100644 drivers/net/wireless/iwl-debug.h
>  create mode 100644 drivers/net/wireless/iwl-eeprom.h
>  create mode 100644 drivers/net/wireless/iwl-helpers.h
>  create mode 100644 drivers/net/wireless/iwl-hw.h
>  create mode 100644 drivers/net/wireless/iwl-io.h
>  create mode 100644 drivers/net/wireless/iwl-priv.h
>  create mode 100644 drivers/net/wireless/iwl-prph.h
>  create mode 100644 drivers/net/wireless/iwl-spectrum.h
>  create mode 100644 drivers/net/wireless/iwl3945-base.c
>  create mode 100644 drivers/net/wireless/iwl4965-base.c
>  create mode 100644 drivers/net/wireless/iwlwifi.h
> -- 
> John W. Linville
> linville@tuxdriver.com
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---
