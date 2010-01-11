From: Amit Salecha <amit.salecha@qlogic.com>
Subject: Re: [PATCHv3 NEXT 1/2] qlcnic: Qlogic ethernet driver for CNA devices
Date: Mon, 11 Jan 2010 17:43:33 +0530
Message-ID: <4B4B15ED.7070201@qlogic.com>
References: <1262867712-32519-1-git-send-email-amit.salecha@qlogic.com> <1262867712-32519-2-git-send-email-amit.salecha@qlogic.com> <1262983921.17358.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:5847 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab0AKMKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 07:10:17 -0500
In-Reply-To: <1262983921.17358.5.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
    Thanks for review.
     I will send updated patches as v4, incorporating valid suggestion.
Regards
Amit Salecha

Ben Hutchings wrote:
> On Thu, 2010-01-07 at 04:35 -0800, Amit Kumar Salecha wrote:
>  =20
>> o 1G/10G Ethernet Driver for Qlgic QLE8240 and QLE8242 CNA devices.
>>    =20
>
> 'o'?  You're addressing this message to the driver? :-)
>
> [...]
>  =20
>> --- /dev/null
>> +++ b/drivers/net/qlcnic/Makefile
>> @@ -0,0 +1,28 @@
>> +# Copyright (C) 2009 - QLogic Corporation.
>> +# All rights reserved.
>> +#
>> +# This program is free software; you can redistribute it and/or
>> +# modify it under the terms of the GNU General Public License
>> +# as published by the Free Software Foundation; either version 2
>> +# of the License, or (at your option) any later version.
>> +#
>> +# This program is distributed in the hope that it will be useful, b=
ut
>> +# WITHOUT ANY WARRANTY; without even the implied warranty of
>> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> +# GNU General Public License for more details.
>> +#
>> +# You should have received a copy of the GNU General Public License
>> +# along with this program; if not, write to the Free Software
>> +# Foundation, Inc., 59 Temple Place - Suite 330, Boston,
>> +# MA  02111-1307, USA.
>> +#
>> +# The full GNU General Public License is included in this distribut=
ion
>> +# in the file called LICENSE.
>> +#
>> +#
>>    =20
>
> This is a trivial Makefile; do you really think you need to use 5 tim=
es
> as many lines to assert copyright over it?
>
>  =20
>> +obj-$(CONFIG_QLCNIC) :=3D qlcnic.o
>> +
>> +qlcnic-y :=3D qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
>> +     qlcnic_ethtool.o qlcnic_ctx.o
>> diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic=
=2Eh
>> new file mode 100644
>> index 0000000..be48472
>> --- /dev/null
>> +++ b/drivers/net/qlcnic/qlcnic.h
>> @@ -0,0 +1,1318 @@
>> +/*
>> + * Copyright (C) 2009 - QLogic Corporation.
>> + * All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or
>> + * modify it under the terms of the GNU General Public License
>> + * as published by the Free Software Foundation; either version 2
>> + * of the License, or (at your option) any later version.
>> + *
>> + * This program is distributed in the hope that it will be useful, =
but
>> + * WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public Licens=
e
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
>> + * MA  02111-1307, USA.
>> + *
>> + * The full GNU General Public License is included in this distribu=
tion
>> + * in the file called LICENSE.
>>    =20
>
> It may be called 'LICENSE' in your out-of-tree distribution, but it i=
s
> called 'COPYING' in the kernel distribution.
>
> [...]
>  =20
>> +#define _QLCNIC_LINUX_MAJOR 5
>> +#define _QLCNIC_LINUX_MINOR 0
>> +#define _QLCNIC_LINUX_SUBVERSION 0
>> +#define QLCNIC_LINUX_VERSIONID  "5.0.0"
>> +
>> +#define QLCNIC_VERSION_CODE(a, b, c) (((a) << 24) + ((b) << 16) + (=
c))
>> +#define _major(v)    (((v) >> 24) & 0xff)
>> +#define _minor(v)    (((v) >> 16) & 0xff)
>> +#define _build(v)    ((v) & 0xffff)
>> +
>> +/* version in image has weird encoding:
>> + *  7:0  - major
>> + * 15:8  - minor
>> + * 31:16 - build (little endian)
>> + */
>> +#define QLCNIC_DECODE_VERSION(v) \
>> +     QLCNIC_VERSION_CODE(((v) & 0xff), (((v) >> 8) & 0xff), ((v) >>=
 16))
>>    =20
>
> You might be over-engineering this...
>
>  =20
>> +#define QLCNIC_NUM_FLASH_SECTORS (64)
>> +#define QLCNIC_FLASH_SECTOR_SIZE (64 * 1024)
>> +#define QLCNIC_FLASH_TOTAL_SIZE  (QLCNIC_NUM_FLASH_SECTORS \
>> +                                     * QLCNIC_FLASH_SECTOR_SIZE)
>>    =20
>
> You might consider probing for this rather than assuming the flash
> dimensions are going to stay constant.
>
> [...]
>  =20
>> +#define find_diff_among(a, b, range) ((a) < (b) ? ((b)-(a)) : ((b)+=
(range)-(a)))
>>    =20
>
> This is not a very clear name.  It seems to be used only once, in
> qlcnic_tx_avail().  Perhaps it would be clearer to open-code it there=
?
>
>  =20
>> +#define QLCNIC_RCV_PRODUCER_OFFSET   0
>> +#define QLCNIC_RCV_PEG_DB_ID         2
>> +#define QLCNIC_HOST_DUMMY_DMA_SIZE 1024
>> +#define FLASH_SUCCESS 0
>> +
>> +#define ADDR_IN_WINDOW1(off) \
>> +     ((off > QLCNIC_CRB_PCIX_HOST2) && (off < QLCNIC_CRB_MAX)) ? 1 =
: 0
>>    =20
>
> The final '? 1 : 0' is redundant since the '&&' operator always yield=
s a
> value of 1 or 0.  It is also unsafe since there are no parentheses
> around the whole of the macro expansion.
>
> Also 'off' should be parenthesised.
>
> [...]
>  =20
>> =EF=BB=BF+#define QLCNIC_ETHERMTU                    1500
>>    =20
>
> Already named ETH_DATA_LEN.
>
> [...]
>  =20
>> +#define      MAX_NUM_CARDS           4
>>    =20
>
> You want to limit customers to 4 NICs?  Ah, but you don't actually us=
e
> this anywhere.  So delete it.
>
> [...]
>  =20
>> +#define qlcnic_set_msg_peg_id(config_word, val)      \
>> +     ((config_word) &=3D ~3, (config_word) |=3D val & 3)
>> +#define qlcnic_set_msg_privid(config_word)   \
>> +     ((config_word) |=3D 1 << 2)
>> +#define qlcnic_set_msg_count(config_word, val)       \
>> +     ((config_word) &=3D ~(0x7fff<<3), (config_word) |=3D (val & 0x=
7fff) << 3)
>> +#define qlcnic_set_msg_ctxid(config_word, val)       \
>> +     ((config_word) &=3D ~(0x3ff<<18), (config_word) |=3D (val & 0x=
3ff) << 18)
>> +#define qlcnic_set_msg_opcode(config_word, val)      \
>> +     ((config_word) &=3D ~(0xf<<28), (config_word) |=3D (val & 0xf)=
 << 28)
>>    =20
>
> 'val' should be in parentheses.
>
> [...]
>  =20
>> +#define MINIMUM_ETHERNET_FRAME_SIZE  64      /* With FCS */
>>    =20
>
> This name isn't used.
>
>  =20
>> +#define ETHERNET_FCS_SIZE            4
>>    =20
>
> Already named ETH_FCS_LEN.
>
> [...]
>  =20
>> +union qlcnic_nic_intr_coalesce_data_t {
>> +     struct {
>> +             uint16_t        rx_packets;
>> +             uint16_t        rx_time_us;
>> +             uint16_t        tx_packets;
>> +             uint16_t        tx_time_us;
>> +     } data;
>> +     uint64_t                word;
>> +};
>> +
>> +struct qlcnic_nic_intr_coalesce_t {
>> +     uint16_t                        stats_time_us;
>> +     uint16_t                        rate_sample_time;
>> +     uint16_t                        flags;
>> +     uint16_t                        rsvd_1;
>> +     uint32_t                        low_threshold;
>> +     uint32_t                        high_threshold;
>> +     union qlcnic_nic_intr_coalesce_data_t   normal;
>> +     union qlcnic_nic_intr_coalesce_data_t   low;
>> +     union qlcnic_nic_intr_coalesce_data_t   high;
>> +     union qlcnic_nic_intr_coalesce_data_t   irq;
>> +};
>>    =20
>
> I believe these are hardware structure definitions so you need to use
> __le16, __le32, __le64.  If they are in host byte order, use u16, u32=
, u64.
>
> Also drop the '_t'; we don't use such suffixes for aggregate type nam=
es.
>
> [...]
>  =20
>> diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/ql=
cnic_ctx.c
>> new file mode 100644
>> index 0000000..f056b73
>> --- /dev/null
>>    =20
> [...]
>  =20
>> +static u32
>> +qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
>> +     u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd=
)
>> +{
>> +     u32 rsp;
>> +     u32 signature =3D 0;
>> +     u32 rcode =3D QLCNIC_RCODE_SUCCESS;
>> +
>> +     signature =3D QLCNIC_CDRP_SIGNATURE_MAKE(pci_fn, version);
>> +
>> +     /* Acquire semaphore before accessing CRB */
>> +     if (qlcnic_api_lock(adapter))
>> +             return QLCNIC_RCODE_TIMEOUT;
>> +
>> +     QLCWR32(adapter, QLCNIC_SIGN_CRB_OFFSET, signature);
>> +
>> +     QLCWR32(adapter, QLCNIC_ARG1_CRB_OFFSET, arg1);
>> +
>> +     QLCWR32(adapter, QLCNIC_ARG2_CRB_OFFSET, arg2);
>> +
>> +     QLCWR32(adapter, QLCNIC_ARG3_CRB_OFFSET, arg3);
>> +
>> +     QLCWR32(adapter, QLCNIC_CDRP_CRB_OFFSET, QLCNIC_CDRP_FORM_CMD(=
cmd));
>>    =20
>
> I'm not sure
>
> that spacing this out
>
> really makes it more readable.
>
> [...]
>  =20
>> +     if (err) {
>> +             printk(KERN_WARNING
>> +                     "Failed to create rx ctx in firmware%d\n", err=
);
>> +             goto out_free_rsp;
>> +     }
>>    =20
>
> Please use dev_warn(), dev_err(), dev_info() etc. consistently.  I no=
te
> that you are doing so in some places, but there are a lot of printk()=
s
> left.
>
> [...]
>  =20
>> +static int
>> +qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
>> +{
>>    =20
> [...]
>  =20
>> +#if 0
>> +             adapter->tx_state =3D
>> +                     le32_to_cpu(prsp->host_ctx_state);
>> +#endif
>>    =20
>
> Don't use #if 0 - either enable the code or remove it.
>
> [...]
>  =20
>> +void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
>> +{
>> +     struct qlcnic_recv_context *recv_ctx;
>> +     struct qlcnic_host_rds_ring *rds_ring;
>> +     struct qlcnic_host_sds_ring *sds_ring;
>> +     struct qlcnic_host_tx_ring *tx_ring;
>> +     int ring;
>> +
>> +
>> +     if (!test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)=
)
>> +             goto done;
>> +
>> +     qlcnic_fw_cmd_destroy_rx_ctx(adapter);
>> +     qlcnic_fw_cmd_destroy_tx_ctx(adapter);
>> +
>> +     /* Allow dma queues to drain after context reset */
>> +     msleep(20);
>> +
>> +done:
>>    =20
>
> It would be clearer to make the previous three statements a condition=
al
> block.
>
> [...]
>  =20
>> diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcni=
c/qlcnic_ethtool.c
>> new file mode 100644
>> index 0000000..daa192f
>> --- /dev/null
>>    =20
> [...]
>  =20
>> +#define QLC_SIZEOF(m) sizeof(((struct qlcnic_adapter *)0)->m)
>>    =20
>
> Could be defined as 'FIELD_SIZEOF(struct qlnic_adapter, m)'.
>
> [...]
>  =20
>> +static void
>> +qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *=
drvinfo)
>> +{
>> +     struct qlcnic_adapter *adapter =3D netdev_priv(dev);
>> +     u32 fw_major =3D 0;
>> +     u32 fw_minor =3D 0;
>> +     u32 fw_build =3D 0;
>>    =20
>
> Don't initialise variables to dummy values unless you actually intend=
 them to
> be used (clearly not the case here).  This 'defensive coding' just st=
ops the
> compiler from warning if you do forget to assign the proper value lat=
er.
>
>  =20
>> +     strncpy(drvinfo->driver, qlcnic_driver_name, 32);
>> +     strncpy(drvinfo->version, QLCNIC_LINUX_VERSIONID, 32);
>> +     fw_major =3D QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
>> +     fw_minor =3D QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
>> +     fw_build =3D QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
>> +     sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, f=
w_build);
>> +
>> +     strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
>>    =20
>
> It shouldn't make any difference here, but the proper functions for l=
imited-
> length null-terminated strings are strlcpy() and snprintf().
>
>  =20
>> +     drvinfo->regdump_len =3D qlcnic_get_regs_len(dev);
>> +     drvinfo->eedump_len =3D qlcnic_get_eeprom_len(dev);
>>    =20
>
> The ethtool core does this for you.
>
>  =20
>> +}
>> +
>> +static int
>> +qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecm=
d)
>> +{
>>    =20
> [...]
>  =20
>> +     } else if (adapter->ahw.port_type =3D=3D QLCNIC_XGBE) {
>> +             u32 val;
>> +
>> +             val =3D QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
>> +             if (val =3D=3D QLCNIC_PORT_MODE_802_3_AP) {
>> +                     ecmd->supported =3D SUPPORTED_1000baseT_Full;
>> +                     ecmd->advertising =3D ADVERTISED_1000baseT_Ful=
l;
>> +             } else {
>> +                     ecmd->supported =3D SUPPORTED_10000baseT_Full;
>> +                     ecmd->advertising =3D ADVERTISED_10000baseT_Fu=
ll;
>> +             }
>>    =20
>
> Don't abuse the TP mode flags and port type for other media.
>
> Coax and twinax should be reported as port =3D PORT_OTHER.
>
> If you have KX/KX4/KR autoneg ports then there are separate mode flag=
s
> for them.
>
> [...]
>  =20
>> diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/ql=
cnic_hdr.h
>> new file mode 100644
>> index 0000000..5d95ea3
>> --- /dev/null
>> +++ b/drivers/net/qlcnic/qlcnic_hdr.h
>>    =20
> [...]
>  =20
>> +#define FW_POLL_DELAY                        round_jiffies(2 * HZ)
>>    =20
>
> I think you're looking for round_jiffies_relative().  It would make m=
ore
> sense to do the rounding in qlcnic_schedule_work() than each caller,
> though.
>
> [...]
>  =20
>> diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlc=
nic_hw.c
>> new file mode 100644
>> index 0000000..aa7afbe
>> --- /dev/null
>> +++ b/drivers/net/qlcnic/qlcnic_hw.c
>>    =20
> [...]
>  =20
>> +/*
>> + * qlcnic_change_mtu - Change the Maximum Transfer Unit
>> + * @returns 0 on success, negative on failure
>> + */
>> +
>> +#define MTU_FUDGE_FACTOR     100
>>    =20
>
> Unused?
>
>  =20
>> +int qlcnic_change_mtu(struct net_device *netdev, int mtu)
>> +{
>> +     struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
>> +     int max_mtu;
>> +     int rc =3D 0;
>> +
>> +     max_mtu =3D P3_MAX_MTU;
>> +
>> +     if (mtu > max_mtu) {
>> +             printk(KERN_ERR "%s: mtu > %d bytes unsupported\n",
>> +                             netdev->name, max_mtu);
>>    =20
>
> Why not just use P3_MAX_MTU directly instead of the 'variable' max_mt=
u?
>
> [...]
>  =20
>> +int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, __le64 *mac=
)
>> +{
>> +     uint32_t crbaddr, mac_hi, mac_lo;
>> +     int pci_func =3D adapter->ahw.pci_func;
>> +
>> +     crbaddr =3D CRB_MAC_BLOCK_START +
>> +             (4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));
>> +
>> +     mac_lo =3D QLCRD32(adapter, crbaddr);
>> +     mac_hi =3D QLCRD32(adapter, crbaddr+4);
>> +
>> +     if (pci_func & 1)
>> +             *mac =3D le64_to_cpu((mac_lo >> 16) | ((u64)mac_hi << =
16));
>> +     else
>> +             *mac =3D le64_to_cpu((u64)mac_lo | ((u64)mac_hi << 32)=
);
>>    =20
> [...]
>
> *mac has type __le64, so either these le64_to_cpu() calls are wrong o=
r
> mac has been declared wrongly.
>
> I didn't read beyond here.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>  =20

