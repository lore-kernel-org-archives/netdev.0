From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4.10-rc3 00/13] net: dsa: remove unnecessary phy.h include
Date: Tue, 31 Jan 2017 18:42:25 -0800
Message-ID: <cf02354e-bec8-4429-9db4-bb20e262a2e8@gmail.com>
References: <20170118001403.GJ27312@n2100.armlinux.org.uk>
 <20170131191704.GA8281@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jiri Slaby <jirislaby@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
        Nick Kossifidis <mickflemm@gmail.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Satanand Burla <satananda
To: Russell King - ARM Linux <linux@armlinux.org.uk>,
        linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <20170131191704.GA8281@n2100.armlinux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/31/2017 11:17 AM, Russell King - ARM Linux wrote:
> Including phy.h and phy_fixed.h into net/dsa.h causes phy*.h to be an
> unnecessary dependency for quite a large amount of the kernel.  There's
> very little which actually requires definitions from phy.h in net/dsa.h
> - the include itself only wants the declaration of a couple of
> structures and IFNAMSIZ.
> 
> Add linux/if.h for IFNAMSIZ, declarations for the structures, phy.h to
> mv88e6xxx.h as it needs it for phy_interface_t, and remove both phy.h
> and phy_fixed.h from net/dsa.h.
> 
> This patch reduces from around 800 files rebuilt to around 40 - even
> with ccache, the time difference is noticable.
> 
> In order to make this change, several drivers need to be updated to
> include necessary headers that they were picking up through this
> include.  This has resulted in a much larger patch series.
> 
> I'm assuming the 0-day builder has had 24 hours with this series, and
> hasn't reported any further issues with it - the last issue was two
> weeks ago (before I became ill) which I fixed over the last weekend.
> 
> I'm hoping this doesn't conflict with what's already in net-next...

For the entire series:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks a lot for doing that.

> 
>  arch/mips/cavium-octeon/octeon-platform.c             | 4 ----
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h                 | 1 +
>  drivers/net/ethernet/broadcom/bgmac.c                 | 2 ++
>  drivers/net/ethernet/cadence/macb.h                   | 2 ++
>  drivers/net/ethernet/cavium/liquidio/lio_main.c       | 1 +
>  drivers/net/ethernet/cavium/liquidio/lio_vf_main.c    | 1 +
>  drivers/net/ethernet/cavium/liquidio/octeon_console.c | 1 +
>  drivers/net/ethernet/freescale/fman/fman_memac.c      | 1 +
>  drivers/net/ethernet/marvell/mvneta.c                 | 1 +
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.c       | 1 +
>  drivers/net/usb/lan78xx.c                             | 1 +
>  drivers/net/wireless/ath/ath5k/ahb.c                  | 2 +-
>  drivers/target/iscsi/iscsi_target_login.c             | 1 +
>  include/net/dsa.h                                     | 6 ++++--
>  net/core/netprio_cgroup.c                             | 1 +
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c            | 1 +
>  16 files changed, 20 insertions(+), 7 deletions(-)
> 


-- 
Florian
