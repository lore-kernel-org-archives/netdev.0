From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 NEXT 1/2] qlcnic: Qlogic ethernet driver for CNA devices
Date: Fri, 8 Jan 2010 22:00:22 +0000
Message-ID: <1262983921.17358.5.camel@achroite.uk.solarflarecom.com>
References: <1262867712-32519-1-git-send-email-amit.salecha@qlogic.com> <1262867712-32519-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dhananjay.phadke@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:49494 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab0AHWA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 17:00:28 -0500
Content-Disposition: inline
In-Reply-To: <1262867712-32519-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-07 at 04:35 -0800, Amit Kumar Salecha wrote:=20
> o 1G/10G Ethernet Driver for Qlgic QLE8240 and QLE8242 CNA devices.

'o'?  You're addressing this message to the driver? :-)

[...]=20
> --- /dev/null
> +++ b/drivers/net/qlcnic/Makefile
> @@ -0,0 +1,28 @@
> +# Copyright (C) 2009 - QLogic Corporation.
> +# All rights reserved.
> +#
> +# This program is free software; you can redistribute it and/or
> +# modify it under the terms of the GNU General Public License
> +# as published by the Free Software Foundation; either version 2
> +# of the License, or (at your option) any later version.
> +#
> +# This program is distributed in the hope that it will be useful, bu=
t
> +# WITHOUT ANY WARRANTY; without even the implied warranty of
> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +# GNU General Public License for more details.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software
> +# Foundation, Inc., 59 Temple Place - Suite 330, Boston,
> +# MA  02111-1307, USA.
> +#
> +# The full GNU General Public License is included in this distributi=
on
> +# in the file called LICENSE.
> +#
> +#

This is a trivial Makefile; do you really think you need to use 5 times
as many lines to assert copyright over it?

> +obj-$(CONFIG_QLCNIC) :=3D qlcnic.o
> +
> +qlcnic-y :=3D qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
> +	qlcnic_ethtool.o qlcnic_ctx.o
> diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.=
h
> new file mode 100644
> index 0000000..be48472
> --- /dev/null
> +++ b/drivers/net/qlcnic/qlcnic.h
> @@ -0,0 +1,1318 @@
> +/*
> + * Copyright (C) 2009 - QLogic Corporation.
> + * All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful, b=
ut
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
> + * MA  02111-1307, USA.
> + *
> + * The full GNU General Public License is included in this distribut=
ion
> + * in the file called LICENSE.

It may be called 'LICENSE' in your out-of-tree distribution, but it is
called 'COPYING' in the kernel distribution.

[...]=20
> +#define _QLCNIC_LINUX_MAJOR 5
> +#define _QLCNIC_LINUX_MINOR 0
> +#define _QLCNIC_LINUX_SUBVERSION 0
> +#define QLCNIC_LINUX_VERSIONID  "5.0.0"
> +
> +#define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c=
))
> +#define _major(v)	(((v) >> 24) & 0xff)
> +#define _minor(v)	(((v) >> 16) & 0xff)
> +#define _build(v)	((v) & 0xffff)
> +
> +/* version in image has weird encoding:
> + *  7:0  - major
> + * 15:8  - minor
> + * 31:16 - build (little endian)
> + */
> +#define QLCNIC_DECODE_VERSION(v) \
> +	QLCNIC_VERSION_CODE(((v) & 0xff), (((v) >> 8) & 0xff), ((v) >> 16))

You might be over-engineering this...

> +#define QLCNIC_NUM_FLASH_SECTORS (64)
> +#define QLCNIC_FLASH_SECTOR_SIZE (64 * 1024)
> +#define QLCNIC_FLASH_TOTAL_SIZE  (QLCNIC_NUM_FLASH_SECTORS \
> +					* QLCNIC_FLASH_SECTOR_SIZE)

You might consider probing for this rather than assuming the flash
dimensions are going to stay constant.

[...]=20
> +#define find_diff_among(a, b, range) ((a) < (b) ? ((b)-(a)) : ((b)+(=
range)-(a)))

This is not a very clear name.  It seems to be used only once, in
qlcnic_tx_avail().  Perhaps it would be clearer to open-code it there?

> +#define QLCNIC_RCV_PRODUCER_OFFSET	0
> +#define QLCNIC_RCV_PEG_DB_ID		2
> +#define QLCNIC_HOST_DUMMY_DMA_SIZE 1024
> +#define FLASH_SUCCESS 0
> +
> +#define ADDR_IN_WINDOW1(off)	\
> +	((off > QLCNIC_CRB_PCIX_HOST2) && (off < QLCNIC_CRB_MAX)) ? 1 : 0

The final '? 1 : 0' is redundant since the '&&' operator always yields =
a
value of 1 or 0.  It is also unsafe since there are no parentheses
around the whole of the macro expansion.

Also 'off' should be parenthesised.

[...]
> =EF=BB=BF+#define QLCNIC_ETHERMTU                    1500

Already named ETH_DATA_LEN.

[...]=20
> +#define	MAX_NUM_CARDS		4

You want to limit customers to 4 NICs?  Ah, but you don't actually use
this anywhere.  So delete it.

[...]=20
> +#define qlcnic_set_msg_peg_id(config_word, val)	\
> +	((config_word) &=3D ~3, (config_word) |=3D val & 3)
> +#define qlcnic_set_msg_privid(config_word)	\
> +	((config_word) |=3D 1 << 2)
> +#define qlcnic_set_msg_count(config_word, val)	\
> +	((config_word) &=3D ~(0x7fff<<3), (config_word) |=3D (val & 0x7fff)=
 << 3)
> +#define qlcnic_set_msg_ctxid(config_word, val)	\
> +	((config_word) &=3D ~(0x3ff<<18), (config_word) |=3D (val & 0x3ff) =
<< 18)
> +#define qlcnic_set_msg_opcode(config_word, val)	\
> +	((config_word) &=3D ~(0xf<<28), (config_word) |=3D (val & 0xf) << 2=
8)

'val' should be in parentheses.

[...]
> +#define MINIMUM_ETHERNET_FRAME_SIZE	64	/* With FCS */

This name isn't used.

> +#define ETHERNET_FCS_SIZE		4

Already named ETH_FCS_LEN.

[...]
> +union qlcnic_nic_intr_coalesce_data_t {
> +	struct {
> +		uint16_t	rx_packets;
> +		uint16_t	rx_time_us;
> +		uint16_t	tx_packets;
> +		uint16_t	tx_time_us;
> +	} data;
> +	uint64_t		word;
> +};
> +
> +struct qlcnic_nic_intr_coalesce_t {
> +	uint16_t			stats_time_us;
> +	uint16_t			rate_sample_time;
> +	uint16_t			flags;
> +	uint16_t			rsvd_1;
> +	uint32_t			low_threshold;
> +	uint32_t			high_threshold;
> +	union qlcnic_nic_intr_coalesce_data_t	normal;
> +	union qlcnic_nic_intr_coalesce_data_t	low;
> +	union qlcnic_nic_intr_coalesce_data_t	high;
> +	union qlcnic_nic_intr_coalesce_data_t	irq;
> +};

I believe these are hardware structure definitions so you need to use
__le16, __le32, __le64.  If they are in host byte order, use u16, u32, =
u64.

Also drop the '_t'; we don't use such suffixes for aggregate type names=
=2E

[...]
> diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlc=
nic_ctx.c
> new file mode 100644
> index 0000000..f056b73
> --- /dev/null
[...]
> +static u32
> +qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
> +	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd)
> +{
> +	u32 rsp;
> +	u32 signature =3D 0;
> +	u32 rcode =3D QLCNIC_RCODE_SUCCESS;
> +
> +	signature =3D QLCNIC_CDRP_SIGNATURE_MAKE(pci_fn, version);
> +
> +	/* Acquire semaphore before accessing CRB */
> +	if (qlcnic_api_lock(adapter))
> +		return QLCNIC_RCODE_TIMEOUT;
> +
> +	QLCWR32(adapter, QLCNIC_SIGN_CRB_OFFSET, signature);
> +
> +	QLCWR32(adapter, QLCNIC_ARG1_CRB_OFFSET, arg1);
> +
> +	QLCWR32(adapter, QLCNIC_ARG2_CRB_OFFSET, arg2);
> +
> +	QLCWR32(adapter, QLCNIC_ARG3_CRB_OFFSET, arg3);
> +
> +	QLCWR32(adapter, QLCNIC_CDRP_CRB_OFFSET, QLCNIC_CDRP_FORM_CMD(cmd))=
;

I'm not sure

that spacing this out

really makes it more readable.

[...]
> +	if (err) {
> +		printk(KERN_WARNING
> +			"Failed to create rx ctx in firmware%d\n", err);
> +		goto out_free_rsp;
> +	}

Please use dev_warn(), dev_err(), dev_info() etc. consistently.  I note
that you are doing so in some places, but there are a lot of printk()s
left.

[...]
> +static int
> +qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
> +{
[...]
> +#if 0
> +		adapter->tx_state =3D
> +			le32_to_cpu(prsp->host_ctx_state);
> +#endif

Don't use #if 0 - either enable the code or remove it.

[...]
> +void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
> +{
> +	struct qlcnic_recv_context *recv_ctx;
> +	struct qlcnic_host_rds_ring *rds_ring;
> +	struct qlcnic_host_sds_ring *sds_ring;
> +	struct qlcnic_host_tx_ring *tx_ring;
> +	int ring;
> +
> +
> +	if (!test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
> +		goto done;
> +
> +	qlcnic_fw_cmd_destroy_rx_ctx(adapter);
> +	qlcnic_fw_cmd_destroy_tx_ctx(adapter);
> +
> +	/* Allow dma queues to drain after context reset */
> +	msleep(20);
> +
> +done:

It would be clearer to make the previous three statements a conditional
block.

[...]
> diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic=
/qlcnic_ethtool.c
> new file mode 100644
> index 0000000..daa192f
> --- /dev/null
[...]
> +#define QLC_SIZEOF(m) sizeof(((struct qlcnic_adapter *)0)->m)

Could be defined as 'FIELD_SIZEOF(struct qlnic_adapter, m)'.

[...]
> +static void
> +qlcnic_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *d=
rvinfo)
> +{
> +	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
> +	u32 fw_major =3D 0;
> +	u32 fw_minor =3D 0;
> +	u32 fw_build =3D 0;

Don't initialise variables to dummy values unless you actually intend t=
hem to
be used (clearly not the case here).  This 'defensive coding' just stop=
s the
compiler from warning if you do forget to assign the proper value later=
=2E

> +	strncpy(drvinfo->driver, qlcnic_driver_name, 32);
> +	strncpy(drvinfo->version, QLCNIC_LINUX_VERSIONID, 32);
> +	fw_major =3D QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
> +	fw_minor =3D QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
> +	fw_build =3D QLCRD32(adapter, QLCNIC_FW_VERSION_SUB);
> +	sprintf(drvinfo->fw_version, "%d.%d.%d", fw_major, fw_minor, fw_bui=
ld);
> +
> +	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);

It shouldn't make any difference here, but the proper functions for lim=
ited-
length null-terminated strings are strlcpy() and snprintf().

> +	drvinfo->regdump_len =3D qlcnic_get_regs_len(dev);
> +	drvinfo->eedump_len =3D qlcnic_get_eeprom_len(dev);

The ethtool core does this for you.

> +}
> +
> +static int
> +qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd=
)
> +{
[...]
> +	} else if (adapter->ahw.port_type =3D=3D QLCNIC_XGBE) {
> +		u32 val;
> +
> +		val =3D QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
> +		if (val =3D=3D QLCNIC_PORT_MODE_802_3_AP) {
> +			ecmd->supported =3D SUPPORTED_1000baseT_Full;
> +			ecmd->advertising =3D ADVERTISED_1000baseT_Full;
> +		} else {
> +			ecmd->supported =3D SUPPORTED_10000baseT_Full;
> +			ecmd->advertising =3D ADVERTISED_10000baseT_Full;
> +		}

Don't abuse the TP mode flags and port type for other media.

Coax and twinax should be reported as port =3D PORT_OTHER.

If you have KX/KX4/KR autoneg ports then there are separate mode flags
for them.

[...]
> diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlc=
nic_hdr.h
> new file mode 100644
> index 0000000..5d95ea3
> --- /dev/null
> +++ b/drivers/net/qlcnic/qlcnic_hdr.h
[...]
> +#define FW_POLL_DELAY			round_jiffies(2 * HZ)

I think you're looking for round_jiffies_relative().  It would make mor=
e
sense to do the rounding in qlcnic_schedule_work() than each caller,
though.

[...]
> diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcn=
ic_hw.c
> new file mode 100644
> index 0000000..aa7afbe
> --- /dev/null
> +++ b/drivers/net/qlcnic/qlcnic_hw.c
[...]
> +/*
> + * qlcnic_change_mtu - Change the Maximum Transfer Unit
> + * @returns 0 on success, negative on failure
> + */
> +
> +#define MTU_FUDGE_FACTOR	100

Unused?

> +int qlcnic_change_mtu(struct net_device *netdev, int mtu)
> +{
> +	struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
> +	int max_mtu;
> +	int rc =3D 0;
> +
> +	max_mtu =3D P3_MAX_MTU;
> +
> +	if (mtu > max_mtu) {
> +		printk(KERN_ERR "%s: mtu > %d bytes unsupported\n",
> +				netdev->name, max_mtu);

Why not just use P3_MAX_MTU directly instead of the 'variable' max_mtu?

[...]
> +int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, __le64 *mac)
> +{
> +	uint32_t crbaddr, mac_hi, mac_lo;
> +	int pci_func =3D adapter->ahw.pci_func;
> +
> +	crbaddr =3D CRB_MAC_BLOCK_START +
> +		(4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));
> +
> +	mac_lo =3D QLCRD32(adapter, crbaddr);
> +	mac_hi =3D QLCRD32(adapter, crbaddr+4);
> +
> +	if (pci_func & 1)
> +		*mac =3D le64_to_cpu((mac_lo >> 16) | ((u64)mac_hi << 16));
> +	else
> +		*mac =3D le64_to_cpu((u64)mac_lo | ((u64)mac_hi << 32));
[...]

*mac has type __le64, so either these le64_to_cpu() calls are wrong or
mac has been declared wrongly.

I didn't read beyond here.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
