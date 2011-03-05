From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 0/8] mostly bonding rx path changes
Date: Sat, 5 Mar 2011 11:30:24 +0100
Message-ID: <20110305103024.GA7799@psychotron.redhat.com>
References: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64960 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab1CEKad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 05:30:33 -0500
Content-Disposition: inline
In-Reply-To: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmitted with more text. Sorry for annoyance :(

Sat, Mar 05, 2011 at 09:29:46AM CET, jpirko@redhat.com wrote:
>This patchset focuses mainly bonding rx path changes.
>
>Depends on "fcoe: correct checking for bonding"
>
>Jiri Pirko (8):
>  af_packet: use skb->skb_iif instead of orig_dev->ifindex
>  bonding: register slave pointer for rx_handler
>  net: get rid of multiple bond-related netdevice->priv_flags
>  bonding: wrap slave state work
>  bonding: get rid of IFF_SLAVE_INACTIVE netdev->priv_flag
>  bonding: move processing of recv handlers into handle_frame()
>  net: introduce rx_handler results and logic around that
>  net: get rid of orig_dev parameter of packet handlers
>
> drivers/block/aoe/aoenet.c       |    2 +-
> drivers/net/bonding/bond_3ad.c   |   31 +-----
> drivers/net/bonding/bond_3ad.h   |    4 +-
> drivers/net/bonding/bond_alb.c   |   46 ++------
> drivers/net/bonding/bond_alb.h   |    1 -
> drivers/net/bonding/bond_main.c  |  217 ++++++++++++-------------------------
> drivers/net/bonding/bond_sysfs.c |   20 +---
> drivers/net/bonding/bonding.h    |   64 ++++++-----
> drivers/net/hamradio/bpqether.c  |    4 +-
> drivers/net/macvlan.c            |   11 +-
> drivers/net/pppoe.c              |    4 +-
> drivers/net/wan/hdlc.c           |    2 +-
> drivers/net/wan/lapbether.c      |    2 +-
> drivers/scsi/fcoe/fcoe.c         |   12 +--
> include/linux/if.h               |   23 ++---
> include/linux/netdevice.h        |   12 ++-
> include/linux/skbuff.h           |    5 +-
> include/net/ax25.h               |    3 +-
> include/net/datalink.h           |    2 +-
> include/net/ip.h                 |    2 +-
> include/net/ipv6.h               |    3 +-
> include/net/irda/irda.h          |    3 +-
> include/net/llc.h                |    8 +-
> include/net/p8022.h              |    3 +-
> include/net/psnap.h              |    3 +-
> include/net/x25.h                |    2 +-
> net/802/p8022.c                  |    3 +-
> net/802/psnap.c                  |    7 +-
> net/802/stp.c                    |    2 +-
> net/8021q/vlan.h                 |    2 +-
> net/8021q/vlan_dev.c             |    2 +-
> net/appletalk/aarp.c             |    2 +-
> net/appletalk/ddp.c              |    6 +-
> net/ax25/ax25_in.c               |    2 +-
> net/batman-adv/hard-interface.c  |    6 +-
> net/bridge/br_input.c            |   25 +++--
> net/bridge/br_private.h          |    2 +-
> net/caif/caif_dev.c              |    2 +-
> net/can/af_can.c                 |    2 +-
> net/core/dev.c                   |   45 ++++----
> net/core/skbuff.c                |    1 -
> net/decnet/af_decnet.c           |    2 +-
> net/decnet/dn_route.c            |    2 +-
> net/dsa/tag_dsa.c                |    2 +-
> net/dsa/tag_edsa.c               |    2 +-
> net/dsa/tag_trailer.c            |    2 +-
> net/econet/af_econet.c           |    2 +-
> net/ieee802154/af_ieee802154.c   |    2 +-
> net/ipv4/arp.c                   |    2 +-
> net/ipv4/ip_input.c              |    2 +-
> net/ipv4/ipconfig.c              |   13 ++-
> net/ipv6/ip6_input.c             |    3 +-
> net/ipx/af_ipx.c                 |    3 +-
> net/irda/irlap_frame.c           |    2 +-
> net/llc/llc_core.c               |    3 +-
> net/llc/llc_input.c              |    8 +-
> net/packet/af_packet.c           |   10 +-
> net/phonet/af_phonet.c           |    3 +-
> net/tipc/eth_media.c             |    2 +-
> net/x25/x25_dev.c                |    2 +-
> 60 files changed, 268 insertions(+), 397 deletions(-)
>
>-- 
>1.7.4
>
