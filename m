From: Thomas Meyer <thomas@m3y3r.de>
Subject: Re: [PATCH] ipv6: sr: Use ARRAY_SIZE macro
Date: Sat, 2 Sep 2017 08:24:02 +0200
Message-ID: <20170902062402.akr7m6zauo6a3xyd@olymp>
References: <20170831141815.28003-1-thomas@m3y3r.de>
 <20170901.183540.2023957151661748902.davem@davemloft.net>
 <1504324315.2361.25.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1504324315.2361.25.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2017 at 08:51:55PM -0700, Joe Perches wrote:
> On Fri, 2017-09-01 at 18:35 -0700, David Miller wrote:
> > From: Thomas Meyer <thomas@m3y3r.de>
> > Date: Thu, 31 Aug 2017 16:18:15 +0200
> > 
> > > Grepping for "sizeof\(.+\) / sizeof\(" found this as one of the first
> > > candidates.
> > > Maybe a coccinelle can catch all of those.
> 
Hi,

> Umm: try scripts/coccinelle/misc/array_size.cocci

Yes, I found out/remembered after I submitted above patch... I used to
run most of the cocci spatches (some just run too long) after each rc1 release, but lost interest/time. nobody seems to
do this regularly, at least for existing spatches.

See 6 patches with Message-ID 20170901212907.5662-1-thomas@m3y3r.de

> Until then, maybe a perl script?
> 
> $ git grep --name-only sizeof.*/.*sizeof drivers/net | \
>   xargs perl -p -i -e 's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\/\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)/ARRAY_SIZE(\1)/g'
> 
> gives:
> 
> $ git diff --stat drivers/net
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c                   |   2 +-
>  drivers/net/ethernet/mellanox/mlx4/fw.c                         |   4 +--
>  drivers/net/ethernet/mellanox/mlx4/main.c                       |   8 +++---
>  drivers/net/wireless/ath/ath9k/ar9003_eeprom.c                  |   2 +-
>  drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phytbl_n.c | 186 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------------------------------------------
>  5 files changed, 101 insertions(+), 101 deletions(-)

Which makes me wonder why cocci didn't found above places...
Also cocci includes linux/kernel.h if not already present.

I will give above regex a try for the whole kernel tree and check for
false positives.

with kind regards
thomas
