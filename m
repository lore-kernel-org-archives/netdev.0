From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts (Hyper-V)
Date: Fri, 15 Apr 2016 08:39:32 -0700
Message-ID: <CAKgT0Uf3saWQn9kdDzJcKJQnZ2Q7r3pSkGVi9-DxHzqofN8vFQ@mail.gmail.com>
References: <1460678121-30308-1-git-send-email-kys@microsoft.com>
	<1460678142-30353-1-git-send-email-kys@microsoft.com>
	<1460678142-30353-2-git-send-email-kys@microsoft.com>
	<CAKgT0UekYae_BrNfecifzbo60TgAeOzDR8a-O_brfTd_A1EcyA@mail.gmail.com>
	<SN2PR03MB19191AD0BEAEAF61499157D2A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>, Robo Bot <apw@canonical.com>,
	Jason Wang <jasowang@redhat.com>,
	"eli@mellanox.com" <eli@mellanox.com>,
	"jackm@mellanox.com" <jackm@mellanox.com>,
	"yevgenyp@mellanox.com" <yevgenyp@mellanox.com>,
	John Ronciak <john.ronciak@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32872 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbcDOPjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 11:39:33 -0400
In-Reply-To: <SN2PR03MB19191AD0BEAEAF61499157D2A0680@SN2PR03MB1919.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 7:49 PM, KY Srinivasan <kys@microsoft.com> wrote:
>
>
>> -----Original Message-----
>> From: Alexander Duyck [mailto:alexander.duyck@gmail.com]
>> Sent: Thursday, April 14, 2016 4:18 PM
>> To: KY Srinivasan <kys@microsoft.com>
>> Cc: David Miller <davem@davemloft.net>; Netdev
>> <netdev@vger.kernel.org>; linux-kernel@vger.kernel.org;
>> devel@linuxdriverproject.org; olaf@aepfle.de; Robo Bot
>> <apw@canonical.com>; Jason Wang <jasowang@redhat.com>;
>> eli@mellanox.com; jackm@mellanox.com; yevgenyp@mellanox.com; John
>> Ronciak <john.ronciak@intel.com>; intel-wired-lan <intel-wired-
>> lan@lists.osuosl.org>
>> Subject: Re: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts
>> (Hyper-V)
>>
>> On Thu, Apr 14, 2016 at 4:55 PM, K. Y. Srinivasan <kys@microsoft.com>
>> wrote:
>> > On Hyper-V, the VF/PF communication is a via software mediated path
>> > as opposed to the hardware mailbox. Make the necessary
>> > adjustments to support Hyper-V.
>> >
>> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
>> > ---
>> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   11 ++
>> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   56 ++++++---
>> >  drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
>> >  drivers/net/ethernet/intel/ixgbevf/vf.c           |  138
>> +++++++++++++++++++++
>> >  drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
>> >  5 files changed, 201 insertions(+), 18 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>> > index 5ac60ee..f8d2a0b 100644
>> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>> > @@ -460,9 +460,13 @@ enum ixbgevf_state_t {
>> >
>> >  enum ixgbevf_boards {
>> >         board_82599_vf,
>> > +       board_82599_vf_hv,
>> >         board_X540_vf,
>> > +       board_X540_vf_hv,
>> >         board_X550_vf,
>> > +       board_X550_vf_hv,
>> >         board_X550EM_x_vf,
>> > +       board_X550EM_x_vf_hv,
>> >  };
>> >
>> >  enum ixgbevf_xcast_modes {
>> > @@ -477,6 +481,13 @@ extern const struct ixgbevf_info
>> ixgbevf_X550_vf_info;
>> >  extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_info;
>> >  extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
>> >
>> > +
>> > +extern const struct ixgbevf_info ixgbevf_82599_vf_hv_info;
>> > +extern const struct ixgbevf_info ixgbevf_X540_vf_hv_info;
>> > +extern const struct ixgbevf_info ixgbevf_X550_vf_hv_info;
>> > +extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info;
>> > +extern const struct ixgbe_mbx_operations ixgbevf_hv_mbx_ops;
>> > +
>> >  /* needed by ethtool.c */
>> >  extern const char ixgbevf_driver_name[];
>> >  extern const char ixgbevf_driver_version[];
>> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> > index 007cbe0..4a0ffac 100644
>> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> > @@ -49,6 +49,7 @@
>> >  #include <linux/if.h>
>> >  #include <linux/if_vlan.h>
>> >  #include <linux/prefetch.h>
>> > +#include <asm/mshyperv.h>
>> >
>> >  #include "ixgbevf.h"
>> >
>> > @@ -62,10 +63,14 @@ static char ixgbevf_copyright[] =
>> >         "Copyright (c) 2009 - 2015 Intel Corporation.";
>> >
>> >  static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
>> > -       [board_82599_vf] = &ixgbevf_82599_vf_info,
>> > -       [board_X540_vf]  = &ixgbevf_X540_vf_info,
>> > -       [board_X550_vf]  = &ixgbevf_X550_vf_info,
>> > -       [board_X550EM_x_vf] = &ixgbevf_X550EM_x_vf_info,
>> > +       [board_82599_vf]        = &ixgbevf_82599_vf_info,
>> > +       [board_82599_vf_hv]     = &ixgbevf_82599_vf_hv_info,
>> > +       [board_X540_vf]         = &ixgbevf_X540_vf_info,
>> > +       [board_X540_vf_hv]      = &ixgbevf_X540_vf_hv_info,
>> > +       [board_X550_vf]         = &ixgbevf_X550_vf_info,
>> > +       [board_X550_vf_hv]      = &ixgbevf_X550_vf_hv_info,
>> > +       [board_X550EM_x_vf]     = &ixgbevf_X550EM_x_vf_info,
>> > +       [board_X550EM_x_vf_hv]  = &ixgbevf_X550EM_x_vf_hv_info,
>> >  };
>> >
>> >  /* ixgbevf_pci_tbl - PCI Device ID Table
>> > @@ -78,9 +83,13 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] =
>> {
>> >   */
>> >  static const struct pci_device_id ixgbevf_pci_tbl[] = {
>> >         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF), board_82599_vf },
>> > +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF_HV),
>> board_82599_vf_hv },
>> >         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF), board_X540_vf },
>> > +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF_HV),
>> board_X540_vf_hv },
>> >         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF), board_X550_vf },
>> > +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF_HV),
>> board_X550_vf_hv },
>> >         {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF),
>> board_X550EM_x_vf },
>> > +       {PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF_HV),
>> board_X550EM_x_vf_hv},
>> >         /* required last entry */
>> >         {0, }
>> >  };
>> > @@ -1809,12 +1818,13 @@ static int ixgbevf_vlan_rx_add_vid(struct
>> net_device *netdev,
>> >  {
>> >         struct ixgbevf_adapter *adapter = netdev_priv(netdev);
>> >         struct ixgbe_hw *hw = &adapter->hw;
>> > -       int err;
>> > +       int err = 0;
>> >
>> >         spin_lock_bh(&adapter->mbx_lock);
>> >
>> >         /* add VID to filter table */
>> > -       err = hw->mac.ops.set_vfta(hw, vid, 0, true);
>> > +       if (hw->mac.ops.set_vfta)
>> > +               err = hw->mac.ops.set_vfta(hw, vid, 0, true);
>> >
>> >         spin_unlock_bh(&adapter->mbx_lock);
>> >
>> > @@ -1835,12 +1845,13 @@ static int ixgbevf_vlan_rx_kill_vid(struct
>> net_device *netdev,
>> >  {
>> >         struct ixgbevf_adapter *adapter = netdev_priv(netdev);
>> >         struct ixgbe_hw *hw = &adapter->hw;
>> > -       int err;
>> > +       int err = 0;
>> >
>> >         spin_lock_bh(&adapter->mbx_lock);
>> >
>> >         /* remove VID from filter table */
>> > -       err = hw->mac.ops.set_vfta(hw, vid, 0, false);
>> > +       if (hw->mac.ops.set_vfta)
>> > +               err = hw->mac.ops.set_vfta(hw, vid, 0, false);
>> >
>> >         spin_unlock_bh(&adapter->mbx_lock);
>> >
>> > @@ -1873,14 +1884,16 @@ static int ixgbevf_write_uc_addr_list(struct
>> net_device *netdev)
>> >                 struct netdev_hw_addr *ha;
>> >
>> >                 netdev_for_each_uc_addr(ha, netdev) {
>> > -                       hw->mac.ops.set_uc_addr(hw, ++count, ha->addr);
>> > +                       if (hw->mac.ops.set_uc_addr)
>> > +                               hw->mac.ops.set_uc_addr(hw, ++count, ha->addr);
>> >                         udelay(200);
>> >                 }
>> >         } else {
>> >                 /* If the list is empty then send message to PF driver to
>> >                  * clear all MAC VLANs on this VF.
>> >                  */
>> > -               hw->mac.ops.set_uc_addr(hw, 0, NULL);
>> > +               if (hw->mac.ops.set_uc_addr)
>> > +                       hw->mac.ops.set_uc_addr(hw, 0, NULL);
>> >         }
>> >
>> >         return count;
>>
>> So if I am understanding this correctly it looks like you cannot read
>> or write any addresses for this device.  Would I be correct in
>> assuming that you get to have the one unicast address that is provided
>> by the PF and that is it?
>
> That is what I have been told by the Windows folks at Intel.

Yeah, so I didn't see the other half of this patchset that has you
using a software interface for the multicast and broadcast traffic.
What I would recommend doing is just writing up a stub function you
can put in vf.c that will allow you to avoid having to add all these
if checks to the code.

>> If so we may want to look at possibly returning some sort of error on
>> these calls so that we can configure the device to indicate that we
>> cannot support any of these filters.
>
> I will do that. So, I am going to check the device ID and return an error.
> Would IXGBE_NOT_IMPLEMENTED be appropriate?

I'd say don't bother returning an error.  You can probably just stub
out the function since if I recall correctly it is a void function
anyway and doesn't provide a return value.

>>
>> > @@ -1908,10 +1921,13 @@ static void ixgbevf_set_rx_mode(struct
>> net_device *netdev)
>> >
>> >         spin_lock_bh(&adapter->mbx_lock);
>> >
>> > -       hw->mac.ops.update_xcast_mode(hw, netdev, xcast_mode);
>> > +       if (hw->mac.ops.update_mc_addr_list)
>> > +               if (hw->mac.ops.update_xcast_mode)
>> > +                       hw->mac.ops.update_xcast_mode(hw, netdev, xcast_mode);
>> >
>> >         /* reprogram multicast list */
>> > -       hw->mac.ops.update_mc_addr_list(hw, netdev);
>> > +       if (hw->mac.ops.update_mc_addr_list)
>> > +               hw->mac.ops.update_mc_addr_list(hw, netdev);
>> >
>> >         ixgbevf_write_uc_addr_list(netdev);
>> >

Same thing for the multicast list as well.

>> > @@ -2074,10 +2090,13 @@ static void ixgbevf_up_complete(struct
>> ixgbevf_adapter *adapter)
>> >
>> >         spin_lock_bh(&adapter->mbx_lock);
>> >
>> > -       if (is_valid_ether_addr(hw->mac.addr))
>> > -               hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
>> > -       else
>> > -               hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
>> > +       if (is_valid_ether_addr(hw->mac.addr)) {
>> > +               if (hw->mac.ops.set_rar)
>> > +                       hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
>> > +       } else {
>> > +               if (hw->mac.ops.set_rar)
>> > +                       hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
>> > +       }
>> >
>> >         spin_unlock_bh(&adapter->mbx_lock);
>> >
>>
>> Same here.  We shouldn't let the user set a MAC address that we cannot
>> support.  We should be returning an error.
>
> Yes; I will return an error.

This is the one that needs to return an error.  That way we should be
able to prevent MAC address changes.

>>
>> > @@ -3672,14 +3691,15 @@ static int ixgbevf_set_mac(struct net_device
>> *netdev, void *p)
>> >         struct ixgbevf_adapter *adapter = netdev_priv(netdev);
>> >         struct ixgbe_hw *hw = &adapter->hw;
>> >         struct sockaddr *addr = p;
>> > -       int err;
>> > +       int err = 0;
>> >
>> >         if (!is_valid_ether_addr(addr->sa_data))
>> >                 return -EADDRNOTAVAIL;
>> >
>> >         spin_lock_bh(&adapter->mbx_lock);
>> >
>> > -       err = hw->mac.ops.set_rar(hw, 0, addr->sa_data, 0);
>> > +       if (hw->mac.ops.set_rar)
>> > +               err = hw->mac.ops.set_rar(hw, 0, addr->sa_data, 0);
>> >
>> >         spin_unlock_bh(&adapter->mbx_lock);
>> >
>>
>> Specifically here.  If hw->mac.ops.set_rar is NULL we cannot allow any
>> MAC address change so we should probably return "-EADDRNOTAVAIL".
>
> Will do.
>>
>> > diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c
>> b/drivers/net/ethernet/intel/ixgbevf/mbx.c
>> > index dc68fea..298a0da 100644
>> > --- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
>> > +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
>> > @@ -346,3 +346,15 @@ const struct ixgbe_mbx_operations
>> ixgbevf_mbx_ops = {
>> >         .check_for_rst  = ixgbevf_check_for_rst_vf,
>> >  };
>> >
>> > +/**
>> > + * Mailbox operations when running on Hyper-V.
>> > + * On Hyper-V, PF/VF communiction is not through the
>> > + * hardware mailbox; this communication is through
>> > + * a software mediated path.
>> > + * Most mail box operations are noop while running on
>> > + * Hyper-V.
>> > + */
>> > +const struct ixgbe_mbx_operations ixgbevf_hv_mbx_ops = {
>> > +       .init_params    = ixgbevf_init_mbx_params_vf,
>> > +       .check_for_rst  = ixgbevf_check_for_rst_vf,
>> > +};
>>
>> I'd say if you aren't going to use a mailbox then don't initialize it.
>> The code was based off of the same code that runs the ixgbe driver.
>> It should be able to function without a mailbox provided the necessary
>> calls are updated in the ixgbe_mac_operations that are used by the
>> hyperv VF.
>>
> Ok; I will change the code.
>
>> > diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c
>> b/drivers/net/ethernet/intel/ixgbevf/vf.c
>> > index 4d613a4..92397fd 100644
>> > --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
>> > +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
>> > @@ -27,6 +27,13 @@
>> >  #include "vf.h"
>> >  #include "ixgbevf.h"
>> >
>> > +/*
>> > + * On Hyper-V, to reset, we need to read from this offset
>> > + * from the PCI config space. This is the mechanism used on
>> > + * Hyper-V to support PF/VF communication.
>> > + */
>> > +#define IXGBE_HV_RESET_OFFSET           0x201
>> > +
>> >  /**
>> >   *  ixgbevf_start_hw_vf - Prepare hardware for Tx/Rx
>> >   *  @hw: pointer to hardware structure
>> > @@ -126,6 +133,23 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw
>> *hw)
>> >  }
>> >
>> >  /**
>> > + * Hyper-V variant; the VF/PF communication is through the PCI
>> > + * config space.
>> > + */
>> > +static s32 ixgbevf_hv_reset_hw_vf(struct ixgbe_hw *hw)
>> > +{
>> > +       int i;
>> > +       struct ixgbevf_adapter *adapter = hw->back;
>> > +
>> > +       for (i = 0; i < 6; i++)
>> > +               pci_read_config_byte(adapter->pdev,
>> > +                                    (i + IXGBE_HV_RESET_OFFSET),
>> > +                                    &hw->mac.perm_addr[i]);
>> > +
>> > +       return 0;
>> > +}
>> > +
>>
>> This bit can be problematic.  What about the case where PCI_MMCONFIG
>> is not defined.  In such a case it will kill this function without
>> reporting an error other than maybe a MAC address that is all 0s or
>> all FF's.
>>
>> You might want to add some sort of check here with some message if
>> such a situation occurs just so it can be easier to debug.
>
> I am a little confused here. This function will only execute when we are handling Hyper-V
> device IDs (while running on Hyper-V). Hyper-V PCI pass-through driver will support the
> config space access.

The kernel has a configuration option called CONFIG_PCI_MMCONFIG.  On
x86 it is usually enabled by default, but it can be disabled.

Right now this bit of code is dependent on it being enabled in order
to function correctly.  Otherwise you will only have access to the
first 256 bytes of the PCI configuration space.  You might want to
explore the possibility of a Kconfig option that would allow you to
only support the HyperV VFs if CONFIG_PCI_MMCONFIG is enabled.

>>
>> > +/**
>> >   *  ixgbevf_stop_hw_vf - Generic stop Tx/Rx units
>> >   *  @hw: pointer to hardware structure
>> >   *
>> > @@ -656,6 +680,68 @@ out:
>> >  }
>> >
>> >  /**
>> > + * Hyper-V variant; there is no mailbox communication.
>> > + */
>> > +static s32 ixgbevf_hv_check_mac_link_vf(struct ixgbe_hw *hw,
>> > +                                       ixgbe_link_speed *speed,
>> > +                                       bool *link_up,
>> > +                                       bool autoneg_wait_to_complete)
>> > +{
>> > +       struct ixgbe_mbx_info *mbx = &hw->mbx;
>> > +       struct ixgbe_mac_info *mac = &hw->mac;
>> > +       s32 ret_val = 0;
>> > +       u32 links_reg;
>> > +
>> > +       /* If we were hit with a reset drop the link */
>> > +       if (!mbx->ops.check_for_rst(hw) || !mbx->timeout)
>> > +               mac->get_link_status = true;
>> > +
>> > +       if (!mac->get_link_status)
>> > +               goto out;
>> > +
>> > +       /* if link status is down no point in checking to see if pf is up */
>> > +       links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
>> > +       if (!(links_reg & IXGBE_LINKS_UP))
>> > +               goto out;
>> > +
>> > +       /* for SFP+ modules and DA cables on 82599 it can take up to 500usecs
>> > +        * before the link status is correct
>> > +        */
>> > +       if (mac->type == ixgbe_mac_82599_vf) {
>> > +               int i;
>> > +
>> > +               for (i = 0; i < 5; i++) {
>> > +                       udelay(100);
>> > +                       links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
>> > +
>> > +                       if (!(links_reg & IXGBE_LINKS_UP))
>> > +                               goto out;
>> > +               }
>> > +       }
>> > +
>> > +       switch (links_reg & IXGBE_LINKS_SPEED_82599) {
>> > +       case IXGBE_LINKS_SPEED_10G_82599:
>> > +               *speed = IXGBE_LINK_SPEED_10GB_FULL;
>> > +               break;
>> > +       case IXGBE_LINKS_SPEED_1G_82599:
>> > +               *speed = IXGBE_LINK_SPEED_1GB_FULL;
>> > +               break;
>> > +       case IXGBE_LINKS_SPEED_100_82599:
>> > +               *speed = IXGBE_LINK_SPEED_100_FULL;
>> > +               break;
>> > +       }
>> > +
>> > +       /* if we passed all the tests above then the link is up and we no
>> > +        * longer need to check for link
>> > +        */
>> > +       mac->get_link_status = false;
>> > +
>> > +out:
>> > +       *link_up = !mac->get_link_status;
>> > +       return ret_val;
>> > +}
>> > +
>>
>> How does this handle the PF resetting?  Seems like you are going to be
>> generating Tx hangs in such a case.
>
> I am not sure how the Windows PF driver communicates this information.
> Do you have any suggestions for this.

You might want to take a look at the fm10k_get_host_state_generic
function.  You could probably do something like the trick we did there
with the TXDCTL in order to detect cases where the PF has reset the VF
so that you could then reset your guest once the PF has come back up.
That way at least you would report link down instead of Tx hang if the
host has reset you.

>>
>> > +/**
>> >   *  ixgbevf_rlpml_set_vf - Set the maximum receive packet length
>> >   *  @hw: pointer to the HW structure
>> >   *  @max_size: value to assign to max frame size
>> > @@ -663,6 +749,19 @@ out:
>> >  void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size)
>> >  {
>> >         u32 msgbuf[2];
>> > +       u32 reg;
>> > +
>> > +       if (x86_hyper == &x86_hyper_ms_hyperv) {
>> > +               /*
>> > +                * If we are on Hyper-V, we implement
>> > +                * this functionality differently.
>> > +                */
>> > +               reg =  IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(0));
>> > +               /* CRC == 4 */
>> > +               reg |= ((max_size + 4) | IXGBE_RXDCTL_RLPML_EN);
>> > +               IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(0), reg);
>> > +               return;
>> > +       }
>> >
>> >         msgbuf[0] = IXGBE_VF_SET_LPE;
>> >         msgbuf[1] = max_size;
>>
>> You would be better off just implementing a hyperv version of this
>> function and avoiding the mailbox call entirely.
> Ok; will do.
>
>>
>> > @@ -679,6 +778,16 @@ int ixgbevf_negotiate_api_version(struct
>> ixgbe_hw *hw, int api)
>> >         int err;
>> >         u32 msg[3];
>> >
>> > +       if (x86_hyper == &x86_hyper_ms_hyperv) {
>> > +               /*
>> > +                * Hyper-V only supports api version ixgbe_mbox_api_10
>> > +                */
>> > +               if (api != ixgbe_mbox_api_10)
>> > +                       return IXGBE_ERR_INVALID_ARGUMENT;
>> > +
>> > +               return 0;
>> > +       }
>> > +
>> >         /* Negotiate the mailbox API version */
>> >         msg[0] = IXGBE_VF_API_NEGOTIATE;
>> >         msg[1] = api;
>>
>> Same here.  Just implement a hyperv version of this function instead
>> of splicing into the existing call.  Also you will need to wrap this
>> code up so that we can build on all architectures, not just x86.
>
> Ok; will do.
>>
>> > @@ -776,22 +885,51 @@ static const struct ixgbe_mac_operations
>> ixgbevf_mac_ops = {
>> >         .set_vfta               = ixgbevf_set_vfta_vf,
>> >  };
>> >
>> > +static const struct ixgbe_mac_operations ixgbevf_hv_mac_ops = {
>> > +       .init_hw                = ixgbevf_init_hw_vf,
>> > +       .reset_hw               = ixgbevf_hv_reset_hw_vf,
>> > +       .start_hw               = ixgbevf_start_hw_vf,
>> > +       .get_mac_addr           = ixgbevf_get_mac_addr_vf,
>> > +       .stop_adapter           = ixgbevf_stop_hw_vf,
>> > +       .setup_link             = ixgbevf_setup_mac_link_vf,
>> > +       .check_link             = ixgbevf_hv_check_mac_link_vf,
>> > +};
>>
>> You might want to consider implementing a set_rar call that will
>> return an error if you try to change the address to anything that is
>> not the permanent addr.
>
> Ok; will do.
>>
>> >  const struct ixgbevf_info ixgbevf_82599_vf_info = {
>> >         .mac = ixgbe_mac_82599_vf,
>> >         .mac_ops = &ixgbevf_mac_ops,
>> >  };
>> >
>> > +const struct ixgbevf_info ixgbevf_82599_vf_hv_info = {
>> > +       .mac = ixgbe_mac_82599_vf,
>> > +       .mac_ops = &ixgbevf_hv_mac_ops,
>> > +};
>> > +
>> >  const struct ixgbevf_info ixgbevf_X540_vf_info = {
>> >         .mac = ixgbe_mac_X540_vf,
>> >         .mac_ops = &ixgbevf_mac_ops,
>> >  };
>> >
>> > +const struct ixgbevf_info ixgbevf_X540_vf_hv_info = {
>> > +       .mac = ixgbe_mac_X540_vf,
>> > +       .mac_ops = &ixgbevf_hv_mac_ops,
>> > +};
>> > +
>> >  const struct ixgbevf_info ixgbevf_X550_vf_info = {
>> >         .mac = ixgbe_mac_X550_vf,
>> >         .mac_ops = &ixgbevf_mac_ops,
>> >  };
>> >
>> > +const struct ixgbevf_info ixgbevf_X550_vf_hv_info = {
>> > +       .mac = ixgbe_mac_X550_vf,
>> > +       .mac_ops = &ixgbevf_hv_mac_ops,
>> > +};
>> > +
>> >  const struct ixgbevf_info ixgbevf_X550EM_x_vf_info = {
>> >         .mac = ixgbe_mac_X550EM_x_vf,
>> >         .mac_ops = &ixgbevf_mac_ops,
>> >  };
>> > +
>> > +const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info = {
>> > +       .mac = ixgbe_mac_X550EM_x_vf,
>> > +       .mac_ops = &ixgbevf_hv_mac_ops,
>> > +};
>> > diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h
>> b/drivers/net/ethernet/intel/ixgbevf/vf.h
>> > index ef9f773..7242a97 100644
>> > --- a/drivers/net/ethernet/intel/ixgbevf/vf.h
>> > +++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
>> > @@ -32,7 +32,9 @@
>> >  #include <linux/interrupt.h>
>> >  #include <linux/if_ether.h>
>> >  #include <linux/netdevice.h>
>> > +#include <asm/hypervisor.h>
>> >
>> > +#include <asm/hypervisor.h>
>>
>> I don't think you need to include this twice.  Also this is a arch
>> specific header file.  You might want to move this to vf.c since that
>> is where you are using the code it provides.  Then you can probably
>> wrap it in an X86 build check so that you don't break the build on
>> other architectures.
>
> I will fix this. Thank you for your detailed comments.

Yeah, if we can get away from including this entirely it would be
preferred.  Odds are we probably don't need it since the device ID is
unique to HyperV hosts anyway.

I'll keep an eye out for the next patch set.

- Alex
