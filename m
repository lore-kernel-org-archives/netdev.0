From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ipv6: sr: Use ARRAY_SIZE macro
Date: Fri, 01 Sep 2017 20:51:55 -0700
Message-ID: <1504324315.2361.25.camel@perches.com>
References: <20170831141815.28003-1-thomas@m3y3r.de>
         <20170901.183540.2023957151661748902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, thomas@m3y3r.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901.183540.2023957151661748902.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-09-01 at 18:35 -0700, David Miller wrote:
> From: Thomas Meyer <thomas@m3y3r.de>
> Date: Thu, 31 Aug 2017 16:18:15 +0200
> 
> > Grepping for "sizeof\(.+\) / sizeof\(" found this as one of the first
> > candidates.
> > Maybe a coccinelle can catch all of those.

Umm: try scripts/coccinelle/misc/array_size.cocci

Until then, maybe a perl script?

$ git grep --name-only sizeof.*/.*sizeof drivers/net | \
  xargs perl -p -i -e 's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\/\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)/ARRAY_SIZE(\1)/g'

gives:

$ git diff --stat drivers/net
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c                   |   2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c                         |   4 +--
 drivers/net/ethernet/mellanox/mlx4/main.c                       |   8 +++---
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c                  |   2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c | 186 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------------------------------------------
 5 files changed, 101 insertions(+), 101 deletions(-)
