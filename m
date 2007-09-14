From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Fri, 14 Sep 2007 12:41:48 -0700
Message-ID: <1189798908.19708.170.camel@localhost>
References: <1188250006.18004.144.camel@localhost>
	 <20070827.143724.38316150.davem@davemloft.net>
	 <1188335521.6062.56.camel@localhost>
	 <20070828.142216.99461544.davem@davemloft.net>
	 <1188598563.6062.191.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2707 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752419AbXINTm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 15:42:58 -0400
In-Reply-To: <1188598563.6062.191.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David?  Did you ever get a chance to look at this?
Do you want me to rebase it against your newer net-2.4.26?

http://repo.or.cz/w/linux-2.6/trivial-mods.git

> I've inlined the include changes, but the entire patch
> is quite large. (300KB)
> 
> MAC address format changes:
> 
> UPPER->lower case changes in MAC addresses in printks.
> presentation from "%x %x..." to "%02x:%02x...". 
> seq_printf uses of mac addresses
> 
> Perhaps the seq_printf changes might cause problems
> with usermode programs.
> 
> please pull from:
> git pull git://repo.or.cz/linux-2.6/trivial-mods.git net-2.6.24-print_mac
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> --
> 
>  include/linux/if_ether.h |    7 +++++++
>  include/net/ieee80211.h  |    5 -----
>  include/net/mac80211.h   |    4 ----
>  3 files changed, 7 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
> index 3213f6f..bb3eb51 100644
> --- a/include/linux/if_ether.h
> +++ b/include/linux/if_ether.h
> @@ -122,4 +122,11 @@ extern struct ctl_table ether_table[];
>  #endif
>  #endif
>  
> +/*
> + *      Display a 6 byte device address (MAC) in a readable format.
> + */
> +#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
> +extern char *print_mac(char* buf, const u8 *addr);
> +#define DECLARE_MAC_BUF(var) char var[18] __maybe_unused
> +
>  #endif	/* _LINUX_IF_ETHER_H */
> diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
> index bbd85cd..164d132 100644
> --- a/include/net/ieee80211.h
> +++ b/include/net/ieee80211.h
> @@ -119,11 +119,6 @@ do { if (ieee80211_debug_level & (level)) \
>  #define IEEE80211_DEBUG(level, fmt, args...) do {} while (0)
>  #endif				/* CONFIG_IEEE80211_DEBUG */
>  
> -/* debug macros not dependent on CONFIG_IEEE80211_DEBUG */
> -
> -#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
> -#define MAC_ARG(x) ((u8*)(x))[0],((u8*)(x))[1],((u8*)(x))[2],((u8*)(x))[3],((u8*)(x))[4],((u8*)(x))[5]
> -
>  /* escape_essid() is intended to be used in debug (and possibly error)
>   * messages. It should never be used for passing essid to user space. */
>  const char *escape_essid(const char *essid, u8 essid_len);
> diff --git a/include/net/mac80211.h b/include/net/mac80211.h
> index ec8c739..6de3ceb 100644
> --- a/include/net/mac80211.h
> +++ b/include/net/mac80211.h
> @@ -1089,8 +1089,4 @@ static inline int ieee80211_get_morefrag(struct ieee80211_hdr *hdr)
>  		IEEE80211_FCTL_MOREFRAGS) != 0;
>  }
>  
> -#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
> -#define MAC_ARG(x) ((u8*)(x))[0], ((u8*)(x))[1], ((u8*)(x))[2], \
> -		   ((u8*)(x))[3], ((u8*)(x))[4], ((u8*)(x))[5]
> -
>  #endif /* MAC80211_H */
> 
> --
> 
>  drivers/net/3c503.c                           |    4 +-
>  drivers/net/3c505.c                           |   10 +-
>  drivers/net/3c507.c                           |    6 +-
>  drivers/net/3c509.c                           |    6 +-
>  drivers/net/3c515.c                           |    4 +-
>  drivers/net/3c523.c                           |   20 +--
>  drivers/net/3c527.c                           |    7 +-
>  drivers/net/3c59x.c                           |    7 +-
>  drivers/net/8139cp.c                          |    8 +-
>  drivers/net/8139too.c                         |    8 +-
>  drivers/net/82596.c                           |   18 +--
>  drivers/net/a2065.c                           |    6 +-
>  drivers/net/ac3200.c                          |    8 +-
>  drivers/net/acenic.c                          |    7 +-
>  drivers/net/amd8111e.c                        |   12 +-
>  drivers/net/apne.c                            |    9 +-
>  drivers/net/ariadne.c                         |   44 +++---
>  drivers/net/arm/am79c961a.c                   |    8 +-
>  drivers/net/arm/at91_ether.c                  |   18 +-
>  drivers/net/arm/ether1.c                      |    8 +-
>  drivers/net/arm/ether3.c                      |    8 +-
>  drivers/net/arm/etherh.c                      |    8 +-
>  drivers/net/at1700.c                          |    4 +-
>  drivers/net/atarilance.c                      |   40 +++---
>  drivers/net/atp.c                             |    8 +-
>  drivers/net/b44.c                             |    9 +-
>  drivers/net/bmac.c                            |    6 +-
>  drivers/net/bnx2.c                            |   12 +-
>  drivers/net/bonding/bond_main.c               |   34 ++---
>  drivers/net/bonding/bond_sysfs.c              |   11 +-
>  drivers/net/cassini.c                         |   11 +-
>  drivers/net/cris/eth_v10.c                    |    8 +-
>  drivers/net/cs89x0.c                          |   15 +--
>  drivers/net/de600.c                           |    6 +-
>  drivers/net/de620.c                           |    8 +-
>  drivers/net/declance.c                        |   14 +-
>  drivers/net/depca.c                           |   13 +-
>  drivers/net/dgrs.c                            |   18 +--
>  drivers/net/dl2k.c                            |    7 +-
>  drivers/net/dm9000.c                          |    9 +-
>  drivers/net/e100.c                            |    9 +-
>  drivers/net/e1000/e1000_main.c                |    5 +-
>  drivers/net/eepro.c                           |    5 +-
>  drivers/net/eepro100.c                        |    9 +-
>  drivers/net/epic100.c                         |    9 +-
>  drivers/net/es3210.c                          |   22 ++--
>  drivers/net/ewrk3.c                           |   16 +--
>  drivers/net/fealnx.c                          |    9 +-
>  drivers/net/fec.c                             |    7 +-
>  drivers/net/forcedeth.c                       |   12 +-
>  drivers/net/gianfar.c                         |    7 +-
>  drivers/net/hamachi.c                         |    8 +-
>  drivers/net/hamradio/bpqether.c               |   23 +--
>  drivers/net/hp-plus.c                         |    6 +-
>  drivers/net/hp.c                              |    5 +-
>  drivers/net/hp100.c                           |    6 +-
>  drivers/net/hydra.c                           |    7 +-
>  drivers/net/ibm_emac/ibm_emac_core.c          |   14 +-
>  drivers/net/ibmlana.c                         |    6 +-
>  drivers/net/ibmveth.c                         |    9 +-
>  drivers/net/ioc3-eth.c                        |   12 +-
>  drivers/net/isa-skeleton.c                    |    5 +-
>  drivers/net/jazzsonic.c                       |   10 +-
>  drivers/net/lance.c                           |    6 +-
>  drivers/net/lguest_net.c                      |    4 +-
>  drivers/net/lib82596.c                        |   18 +--
>  drivers/net/lne390.c                          |    9 +-
>  drivers/net/mac89x0.c                         |   11 +-
>  drivers/net/macb.c                            |    6 +-
>  drivers/net/mace.c                            |    9 +-
>  drivers/net/macmace.c                         |    6 +-
>  drivers/net/macsonic.c                        |   21 +--
>  drivers/net/meth.c                            |    6 +-
>  drivers/net/mv643xx_eth.c                     |    5 +-
>  drivers/net/mvme147.c                         |   11 +-
>  drivers/net/myri10ge/myri10ge.c               |   11 +-
>  drivers/net/myri_sbus.c                       |   29 ++---
>  drivers/net/natsemi.c                         |   11 +-
>  drivers/net/ne-h8300.c                        |    8 +-
>  drivers/net/ne.c                              |    5 +-
>  drivers/net/ne2.c                             |   17 +--
>  drivers/net/ne2k-pci.c                        |   11 +-
>  drivers/net/ne3210.c                          |   11 +-
>  drivers/net/netconsole.c                      |   14 +-
>  drivers/net/netxen/netxen_nic_main.c          |   13 +-
>  drivers/net/netxen/netxen_nic_niu.c           |   14 +-
>  drivers/net/ni5010.c                          |    4 +-
>  drivers/net/ns83820.c                         |    7 +-
>  drivers/net/pasemi_mac.c                      |    6 +-
>  drivers/net/pci-skeleton.c                    |    9 +-
>  drivers/net/pcmcia/3c574_cs.c                 |    9 +-
>  drivers/net/pcmcia/3c589_cs.c                 |   10 +-
>  drivers/net/pcmcia/axnet_cs.c                 |    9 +-
>  drivers/net/pcmcia/fmvj18x_cs.c               |    8 +-
>  drivers/net/pcmcia/nmclan_cs.c                |    9 +-
>  drivers/net/pcmcia/pcnet_cs.c                 |    7 +-
>  drivers/net/pcmcia/smc91c92_cs.c              |    8 +-
>  drivers/net/pcmcia/xirc2ps_cs.c               |    9 +-
>  drivers/net/pppoe.c                           |    8 +-
>  drivers/net/ps3_gelic_net.c                   |    7 +-
>  drivers/net/qla3xxx.c                         |    7 +-
>  drivers/net/rionet.c                          |    6 +-
>  drivers/net/rrunner.c                         |    8 +-
>  drivers/net/s2io.c                            |   11 +-
>  drivers/net/sb1250-mac.c                      |    7 +-
>  drivers/net/seeq8005.c                        |    4 +-
>  drivers/net/sgiseeq.c                         |    6 +-
>  drivers/net/sis190.c                          |   10 +-
>  drivers/net/sis900.c                          |    9 +-
>  drivers/net/skge.c                            |    7 +-
>  drivers/net/sky2.c                            |    7 +-
>  drivers/net/smc-mca.c                         |    8 +-
>  drivers/net/smc-ultra.c                       |    8 +-
>  drivers/net/smc-ultra32.c                     |    8 +-
>  drivers/net/smc9194.c                         |    7 +-
>  drivers/net/smc91x.c                          |    9 +-
>  drivers/net/starfire.c                        |   26 ++--
>  drivers/net/sun3lance.c                       |   36 ++---
>  drivers/net/sunbmac.c                         |    8 +-
>  drivers/net/sundance.c                        |   10 +-
>  drivers/net/sungem.c                          |   12 +-
>  drivers/net/sunhme.c                          |   12 +-
>  drivers/net/sunlance.c                        |    9 +-
>  drivers/net/tokenring/abyss.c                 |   12 +-
>  drivers/net/tokenring/ibmtr.c                 |   26 ++--
>  drivers/net/tokenring/lanstreamer.c           |   64 ++++-----
>  drivers/net/tokenring/madgemc.c               |   19 +--
>  drivers/net/tokenring/olympic.c               |  138 +++++++---------
>  drivers/net/tokenring/proteon.c               |    8 +-
>  drivers/net/tokenring/skisa.c                 |    8 +-
>  drivers/net/tokenring/tmspci.c                |   10 +-
>  drivers/net/tsi108_eth.c                      |    7 +-
>  drivers/net/tulip/de2104x.c                   |    9 +-
>  drivers/net/tulip/de4x5.c                     |   33 +---
>  drivers/net/tulip/dmfe.c                      |   15 +-
>  drivers/net/tulip/tulip_core.c                |   15 +-
>  drivers/net/tulip/uli526x.c                   |    9 +-
>  drivers/net/tulip/winbond-840.c               |   29 ++--
>  drivers/net/tulip/xircom_cb.c                 |    7 +-
>  drivers/net/tun.c                             |   33 ++---
>  drivers/net/typhoon.c                         |   10 +-
>  drivers/net/usb/pegasus.c                     |   11 +-
>  drivers/net/usb/usbnet.c                      |    8 +-
>  drivers/net/via-rhine.c                       |   13 +-
>  drivers/net/wd.c                              |    7 +-
>  drivers/net/wireless/airo.c                   |   32 ++---
>  drivers/net/wireless/arlan-main.c             |   23 ++--
>  drivers/net/wireless/atmel.c                  |    7 +-
>  drivers/net/wireless/bcm43xx/bcm43xx.h        |    6 -
>  drivers/net/wireless/hostap/hostap_80211_rx.c |   49 ++++---
>  drivers/net/wireless/hostap/hostap_80211_tx.c |   13 +-
>  drivers/net/wireless/hostap/hostap_ap.c       |  198 ++++++++++++++----------
>  drivers/net/wireless/hostap/hostap_common.h   |    3 -
>  drivers/net/wireless/hostap/hostap_hw.c       |   11 +-
>  drivers/net/wireless/hostap/hostap_info.c     |   17 ++-
>  drivers/net/wireless/hostap/hostap_ioctl.c    |   15 +-
>  drivers/net/wireless/hostap/hostap_main.c     |   30 ++--
>  drivers/net/wireless/hostap/hostap_proc.c     |   15 +-
>  drivers/net/wireless/ipw2100.c                |   48 +++---
>  drivers/net/wireless/ipw2200.c                |  207 ++++++++++++++-----------
>  drivers/net/wireless/libertas/assoc.c         |   19 ++-
>  drivers/net/wireless/libertas/cmdresp.c       |    7 +-
>  drivers/net/wireless/libertas/debugfs.c       |    5 +-
>  drivers/net/wireless/libertas/join.c          |   15 +-
>  drivers/net/wireless/libertas/main.c          |   12 +-
>  drivers/net/wireless/libertas/scan.c          |   14 +-
>  drivers/net/wireless/libertas/wext.c          |    5 +-
>  drivers/net/wireless/netwave_cs.c             |   14 +-
>  drivers/net/wireless/orinoco.c                |    7 +-
>  drivers/net/wireless/prism54/isl_ioctl.c      |   50 ++----
>  drivers/net/wireless/ray_cs.c                 |   15 +-
>  drivers/net/wireless/rtl8187_dev.c            |    7 +-
>  drivers/net/wireless/wavelan.c                |   53 +++----
>  drivers/net/wireless/wavelan_cs.c             |   54 +++----
>  drivers/net/wireless/wl3501_cs.c              |   22 ++--
>  drivers/net/wireless/zd1211rw/zd_chip.c       |    3 +-
>  drivers/net/wireless/zd1211rw/zd_mac.c        |    8 +-
>  drivers/net/yellowfin.c                       |   19 +--
>  drivers/net/znet.c                            |   11 +-
>  drivers/net/zorro8390.c                       |   15 +-
>  180 files changed, 1305 insertions(+), 1504 deletions(-)
> 
> --
> 
>  net/802/tr.c                                   |   28 ++--
>  net/appletalk/aarp.c                           |    9 +-
>  net/atm/br2684.c                               |   16 +--
>  net/atm/lec.c                                  |   33 ++---
>  net/core/dev.c                                 |   13 ++
>  net/core/netpoll.c                             |   12 +--
>  net/core/pktgen.c                              |   17 +--
>  net/ethernet/eth.c                             |    8 +
>  net/ieee80211/ieee80211_crypt_ccmp.c           |   30 +++--
>  net/ieee80211/ieee80211_crypt_tkip.c           |   31 +++--
>  net/ieee80211/ieee80211_rx.c                   |   59 +++++----
>  net/ieee80211/ieee80211_wx.c                   |    5 +-
>  net/ieee80211/softmac/ieee80211softmac_assoc.c |    4 +-
>  net/ieee80211/softmac/ieee80211softmac_auth.c  |   35 +++--
>  net/ieee80211/softmac/ieee80211softmac_wx.c    |    5 +-
>  net/irda/irlan/irlan_client.c                  |    6 +-
>  net/llc/llc_proc.c                             |   12 +-
>  net/mac80211/debugfs_key.c                     |    3 +-
>  net/mac80211/debugfs_netdev.c                  |    3 +-
>  net/mac80211/debugfs_sta.c                     |    6 +-
>  net/mac80211/event.c                           |    5 +-
>  net/mac80211/ieee80211.c                       |    5 +-
>  net/mac80211/ieee80211_ioctl.c                 |    5 +-
>  net/mac80211/ieee80211_sta.c                   |  180 +++++++++++++-----------
>  net/mac80211/key.c                             |   10 +-
>  net/mac80211/rc80211_simple.c                  |    5 +-
>  net/mac80211/rx.c                              |  118 +++++++++------
>  net/mac80211/sta_info.c                        |   13 +-
>  net/mac80211/tkip.c                            |   10 +-
>  net/mac80211/tx.c                              |   32 +++--
>  net/mac80211/wpa.c                             |   19 ++-
>  net/tipc/eth_media.c                           |    4 +-
>  32 files changed, 414 insertions(+), 327 deletions(-)
> 

