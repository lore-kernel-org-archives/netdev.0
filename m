From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v3 1/8] i40e: main driver core
Date: Fri, 30 Aug 2013 12:19:20 -0700
Message-ID: <1377890360.2070.36.camel@joe-AO722>
References: <1377866347-23846-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377880368.2070.26.camel@joe-AO722>
	 <20130830111029.25d6d753@nehalam.linuxnetplumber.net>
	 <20130830.144000.1005297116915822361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, shannon.nelson@intel.com,
	peter.p.waskiewicz.jr@intel.com, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51783 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756641Ab3H3TTV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 15:19:21 -0400
In-Reply-To: <20130830.144000.1005297116915822361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-30 at 14:40 -0400, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Fri, 30 Aug 2013 11:10:29 -0700
> 
> > On Fri, 30 Aug 2013 09:32:48 -0700
> > Joe Perches <joe@perches.com> wrote:
> > 
> >> > +static int debug = -1;
> >> > +module_param(debug, int, 0);
> >> > +MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");  
> >> 
> >> Maybe make debug a bitfield instead?
> > 
> > No Joe, this is the standard mapping of debug to msglevel used
> > by most network devices.

OK, I didn't really know how it was being used here.
There's no real standard for that use btw.

(longish list and another comment below)

$ git grep -E "MODULE_PARM_DESC.*\bdebug\b" drivers/net/ethernet
drivers/net/ethernet/3com/3c509.c:MODULE_PARM_DESC(debug, "debug level (0-6)");
drivers/net/ethernet/3com/3c515.c:MODULE_PARM_DESC(debug, "3c515 debug level (0-6)");
drivers/net/ethernet/3com/3c59x.c:MODULE_PARM_DESC(debug, "3c59x debug level (0-6)");
drivers/net/ethernet/8390/ne2k-pci.c:MODULE_PARM_DESC(debug, "debug level (1-2)");
drivers/net/ethernet/adaptec/starfire.c:MODULE_PARM_DESC(debug, "Debug level (0-6)");
drivers/net/ethernet/amd/atarilance.c:MODULE_PARM_DESC(lance_debug, "atarilance debug level (0-3)");
drivers/net/ethernet/amd/lance.c:MODULE_PARM_DESC(lance_debug, "LANCE/PCnet debug level (0-7)");
drivers/net/ethernet/amd/pcnet32.c:MODULE_PARM_DESC(debug, DRV_NAME " debug level");
drivers/net/ethernet/amd/sun3lance.c:MODULE_PARM_DESC(lance_debug, "SUN3 Lance debug level (0-3)");
drivers/net/ethernet/atheros/atlx/atl1.c:MODULE_PARM_DESC(debug, "Message level (0=none,...,16=all)");
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:MODULE_PARM_DESC(mrrs, " Force Max Read Req Size (0..3) (for debug)");
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:MODULE_PARM_DESC(debug, " Default debug msglevel");
drivers/net/ethernet/broadcom/sb1250-mac.c:MODULE_PARM_DESC(debug, "Debug messages");
drivers/net/ethernet/cirrus/cs89x0.c:MODULE_PARM_DESC(debug, "cs89x0 debug level (0-6)");
drivers/net/ethernet/cirrus/cs89x0.c:MODULE_PARM_DESC(debug, "(ignored)");
drivers/net/ethernet/cirrus/mac89x0.c:MODULE_PARM_DESC(debug, "CS89[02]0 debug level (0-5)");
drivers/net/ethernet/davicom/dm9000.c:MODULE_PARM_DESC(debug, "dm9000 debug level (0-4)");
drivers/net/ethernet/dec/tulip/de2104x.c:MODULE_PARM_DESC (debug, "de2104x bitmapped message enable number");
drivers/net/ethernet/dec/tulip/de4x5.c:MODULE_PARM_DESC(de4x5_debug, "de4x5 debug mask");
drivers/net/ethernet/dec/tulip/dmfe.c:MODULE_PARM_DESC(debug, "Davicom DM9xxx enable debugging (0-1)");
drivers/net/ethernet/dec/tulip/uli526x.c:MODULE_PARM_DESC(debug, "ULi M5261/M5263 enable debugging (0-1)");
drivers/net/ethernet/dec/tulip/winbond-840.c:MODULE_PARM_DESC(debug, "winbond-840 debug level (0-6)");
drivers/net/ethernet/dlink/sundance.c:MODULE_PARM_DESC(debug, "Sundance Alta debug level (0-5)");
drivers/net/ethernet/fealnx.c:MODULE_PARM_DESC(debug, "fealnx enable debugging (0-1)");
drivers/net/ethernet/freescale/fec_mpc52xx.c:MODULE_PARM_DESC(debug, "debugging messages level");
drivers/net/ethernet/freescale/ucc_geth.c:MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 0xffff=all)");
drivers/net/ethernet/i825xx/82596.c:MODULE_PARM_DESC(i596_debug, "i82596 debug mask");
drivers/net/ethernet/i825xx/82596.c:MODULE_PARM_DESC(debug, "i82596 debug mask");
drivers/net/ethernet/i825xx/lasi_82596.c:MODULE_PARM_DESC(i596_debug, "lasi_82596 debug mask");
drivers/net/ethernet/i825xx/sni_82596.c:MODULE_PARM_DESC(i596_debug, "82596 debug mask");
drivers/net/ethernet/intel/e100.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/e1000/e1000_main.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/e1000e/netdev.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/i40e/i40e_main.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/igb/igb_main.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/igbvf/netdev.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/ixgb/ixgb_main.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/marvell/skge.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/marvell/sky2.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/mellanox/mlx4/main.c:MODULE_PARM_DESC(debug_level, "Enable debug tracing if > 0");
drivers/net/ethernet/mellanox/mlx5/core/main.c:MODULE_PARM_DESC(debug_mask, "debug mask: 1 = dump cmd data, 2 = dump cmd exec time, 3 = both. Default=0");
drivers/net/ethernet/microchip/enc28j60.c:MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., ffff=all)");
drivers/net/ethernet/natsemi/jazzsonic.c:MODULE_PARM_DESC(sonic_debug, "jazzsonic debug level (1-4)");
drivers/net/ethernet/natsemi/macsonic.c:MODULE_PARM_DESC(sonic_debug, "macsonic debug level (1-4)");
drivers/net/ethernet/natsemi/natsemi.c:MODULE_PARM_DESC(debug, "DP8381x default debug level");
drivers/net/ethernet/natsemi/xtsonic.c:MODULE_PARM_DESC(sonic_debug, "xtsonic debug level (1-4)");
drivers/net/ethernet/packetengines/hamachi.c:MODULE_PARM_DESC(debug, "GNIC-II debug level (0-7)");
drivers/net/ethernet/packetengines/yellowfin.c:MODULE_PARM_DESC(debug, "G-NIC debug level (0-7)");
drivers/net/ethernet/pasemi/pasemi_mac.c:MODULE_PARM_DESC(debug, "PA Semi MAC bitmapped debugging message enable value");
drivers/net/ethernet/qlogic/qla3xxx.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/qlogic/qlge/qlge_main.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/realtek/8139cp.c:MODULE_PARM_DESC (debug, "8139cp: bitmapped message enable number");
drivers/net/ethernet/realtek/8139too.c:MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
drivers/net/ethernet/realtek/atp.c:MODULE_PARM_DESC(debug, "ATP debug level (0-7)");
drivers/net/ethernet/realtek/r8169.c:MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
drivers/net/ethernet/sfc/efx.c:MODULE_PARM_DESC(debug, "Bitmapped debugging message enable value");
drivers/net/ethernet/sis/sis190.c:MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
drivers/net/ethernet/smsc/epic100.c:MODULE_PARM_DESC(debug, "EPIC/100 debug level (0-5)");
drivers/net/ethernet/smsc/smsc911x.c:MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
drivers/net/ethernet/smsc/smsc9420.c:MODULE_PARM_DESC(debug, "debug level");
drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:MODULE_PARM_DESC(debug, "Message Level (-1: default, 0: no output, 16: all)");
drivers/net/ethernet/sun/niu.c:MODULE_PARM_DESC(debug, "NIU debug level");
drivers/net/ethernet/ti/cpsw.c:MODULE_PARM_DESC(debug_level, "cpsw debug level (NETIF_MSG bits)");
drivers/net/ethernet/ti/davinci_emac.c:MODULE_PARM_DESC(debug_level, "DaVinci EMAC debug level (NETIF_MSG bits)");
drivers/net/ethernet/ti/tlan.c:MODULE_PARM_DESC(debug, "ThunderLAN debug mask");
drivers/net/ethernet/via/via-rhine.c:MODULE_PARM_DESC(debug, "VIA Rhine debug message flags");

> > The debug parameter is converted
> > to mask by netif_msg_init.
> 
> Correct.

Swell, I think the module parm description is misleading.

I think it'd be better to reference "(NETIF_MSG bits)" like
the TI drivers do.
