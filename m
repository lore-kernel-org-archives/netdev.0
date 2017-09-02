From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: add master interface
Date: Sat, 2 Sep 2017 09:42:01 -0700
Message-ID: <a49d59fb-956f-a849-7add-ec2ed0de197b@gmail.com>
References: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien,

On 08/31/2017 11:37 AM, Vivien Didelot wrote:
> Currently the SoC network interface (called master) to which a switch
> fabric hangs, has its dsa_ptr pointing to a dsa_switch_tree instance.
> 
> This is not quite correct, because this interface is physically wired to
> one of the switch ports (called CPU port), and because in a switch
> fabric with multiple CPU ports, several master interfaces will point to
> several CPU ports of the same dsa_switch_tree.
> 
> This patchset adds a new dsa_master structure to represent the pipe
> between the SoC master interface and its switch CPU port. This structure
> will store specific data such as the master ethtool_ops copy and the
> tagging protocol used to pass frames with the associated slave ports.
> The dsa_ptr is changed to a dsa_master instance, and each DSA slave now
> has a pointer to a master port.
> 
> This is a step forward better control over the CPU conduit and support
> for multiple CPU ports.

Looked briefly over this series and this looks good to me, Andrew has a
valid point about reducing the number of dereferences in hot paths
though. Thanks!

> 
> Vivien Didelot (4):
>   net: dsa: introduce dsa_master
>   net: dsa: move master ethtool ops in dsa_master
>   net: dsa: change dsa_ptr for a dsa_master
>   net: dsa: assign a master to slave ports
> 
>  drivers/net/dsa/b53/b53_common.c |   4 +-
>  drivers/net/dsa/bcm_sf2.c        |   8 +--
>  drivers/net/dsa/mt7530.c         |   4 +-
>  drivers/net/dsa/mv88e6060.c      |   2 +-
>  drivers/net/dsa/qca8k.c          |   2 +-
>  include/linux/netdevice.h        |   4 +-
>  include/net/dsa.h                |  42 +++++------
>  net/dsa/Makefile                 |   2 +-
>  net/dsa/dsa.c                    |  34 +--------
>  net/dsa/dsa2.c                   |  38 +++++-----
>  net/dsa/dsa_priv.h               |  24 +++----
>  net/dsa/legacy.c                 |  34 +++++----
>  net/dsa/master.c                 | 149 +++++++++++++++++++++++++++++++++++++++
>  net/dsa/slave.c                  | 117 +++++-------------------------
>  net/dsa/tag_brcm.c               |   5 +-
>  net/dsa/tag_dsa.c                |   3 +-
>  net/dsa/tag_edsa.c               |   3 +-
>  net/dsa/tag_ksz.c                |   5 +-
>  net/dsa/tag_lan9303.c            |   6 +-
>  net/dsa/tag_mtk.c                |  12 +---
>  net/dsa/tag_qca.c                |  12 +---
>  net/dsa/tag_trailer.c            |   5 +-
>  22 files changed, 265 insertions(+), 250 deletions(-)
>  create mode 100644 net/dsa/master.c
> 

-- 
Florian
