From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH net-next 0/4] net-next: dsa: add Mediatek MT7530 support
Date: Mon, 13 Mar 2017 17:25:30 +0100
Message-ID: <09927247-dd22-d341-e58c-c8f36fba4755@phrozen.org>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1489421488-300-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org



On 13/03/17 17:11, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
> From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
>
> MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
> Mediatek router platforms such as MT7623A or MT7623N which includes 7-port
> Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY. Among these ports,
> The port from 0 to 4 are the user ports connecting with the remote devices
> while the port 5 and 6 are the CPU ports connecting into Mediatek Ethernet
> GMAC.
>
> The patch series integrated Mediatek MT7530 into DSA support which
> includes the most of the essential callbacks such as tag insertion for
> port distinguishing, port control, bridge offloading, STP setup and
> ethtool operations to allow DSA to model each user port into independently
> standalone netdevice as the other DSA driver had done.
Hi Sean,

very cool, i'll give this a spin this week and if it works out will 
import it into LEDE to get test coverage from our users.

     John

> Sean Wang (4):
>    dt-bindings: net: dsa: add mt7530 binding
>    net-next: dsa: add Mediatek tag RX/TX handler
>    net-next: ethernet: mediatek: add CMD ingress recognize the special
>      tag
>    net-next: dsa: add dsa support for Mediatek MT7530 switch
>
>   .../devicetree/bindings/net/dsa/mt7530.txt         |   96 ++
>   drivers/net/dsa/Kconfig                            |    8 +
>   drivers/net/dsa/Makefile                           |    2 +-
>   drivers/net/dsa/mt7530.c                           | 1195 ++++++++++++++++++++
>   drivers/net/dsa/mt7530.h                           |  387 +++++++
>   drivers/net/ethernet/mediatek/mtk_eth_soc.c        |    8 +
>   drivers/net/ethernet/mediatek/mtk_eth_soc.h        |    5 +
>   include/net/dsa.h                                  |    1 +
>   net/dsa/Kconfig                                    |    2 +
>   net/dsa/Makefile                                   |    1 +
>   net/dsa/dsa.c                                      |    3 +
>   net/dsa/dsa_priv.h                                 |    3 +
>   net/dsa/tag_mtk.c                                  |  121 ++
>   13 files changed, 1831 insertions(+), 1 deletion(-)
>   create mode 100644 Documentation/devicetree/bindings/net/dsa/mt7530.txt
>   create mode 100644 drivers/net/dsa/mt7530.c
>   create mode 100644 drivers/net/dsa/mt7530.h
>   create mode 100644 net/dsa/tag_mtk.c
>
