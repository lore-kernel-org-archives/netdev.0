From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/8] net: dsa: change dsa_ptr for a dsa_port
Date: Fri, 29 Sep 2017 12:26:07 -0700
Message-ID: <03cef84e-546d-d8c2-85fb-afc697ced2cb@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> With DSA, a master net_device is physically wired to a dedicated CPU
> switch port. For interaction with the DSA layer, the struct net_device
> contains a dsa_ptr, which currently points to a dsa_switch_tree object.
> 
> This is only valid for a switch fabric with a single CPU port. In order
> to support switch fabrics with multiple CPU ports, we first need to
> change the type of dsa_ptr to what it really is: a dsa_port object.
> 
> This is what this patchset does. The first 4 patches cleans up portions
> of DSA core to make the next patches more readable. These next patches
> prepare the xmit and receive hot paths and finally change dsa_ptr.

This looks nice and clean, as mentioned in patch 5, there may be room
for organizing the structure a bit more efficiently such that everything
still fits within the first cacheline .

> 
> Vivien Didelot (8):
>   net: dsa: directly fetch switch in mtk_tag_rcv
>   net: dsa: directly fetch switch in lan9303_rcv
>   net: dsa: use cpu_dp in master code
>   net: dsa: use temporary dsa_device_ops variable
>   net: dsa: add tagging ops to port
>   net: dsa: prepare master receive hot path
>   net: dsa: change dsa_ptr for a dsa_port
>   net: dsa: remove tag ops from the switch tree
> 
>  include/linux/netdevice.h |  4 ++--
>  include/net/dsa.h         | 19 ++++++++-----------
>  net/dsa/dsa.c             |  6 +++---
>  net/dsa/dsa2.c            | 15 ++++++++++-----
>  net/dsa/dsa_priv.h        |  7 +------
>  net/dsa/legacy.c          | 15 ++++++++++-----
>  net/dsa/master.c          | 47 ++++++++++++++++++++++-------------------------
>  net/dsa/slave.c           |  3 +--
>  net/dsa/tag_brcm.c        |  3 +--
>  net/dsa/tag_dsa.c         |  3 ++-
>  net/dsa/tag_edsa.c        |  3 ++-
>  net/dsa/tag_ksz.c         |  3 +--
>  net/dsa/tag_lan9303.c     |  6 ++----
>  net/dsa/tag_mtk.c         | 12 ++----------
>  net/dsa/tag_qca.c         |  3 +--
>  net/dsa/tag_trailer.c     |  3 +--
>  16 files changed, 69 insertions(+), 83 deletions(-)
> 


-- 
Florian
