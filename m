From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.17 3/9] NetXen: Registers info header file.
Date: Wed, 05 Jul 2006 11:51:48 -0400
Message-ID: <44ABE014.6010407@garzik.org>
References: <Pine.LNX.4.64.0607050602310.27969@dut46> <Pine.LNX.4.64.0607050629100.27969@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16782 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932421AbWGEPvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 11:51:51 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.64.0607050629100.27969@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linsys Contractor Amit S. Kale wrote:
=> +extern struct netxen_adapter *g_adapter;
> +
> +/*
> + * The basic unit of access when reading/writing control registers.
> + */
> +
> +typedef u32 netxen_crbword_t;    /* single word in CRB space */
> +
> +#define NETXEN_HW_H0_CH_HUB_ADR    0x05
> +#define NETXEN_HW_H1_CH_HUB_ADR    0x0E
> +#define NETXEN_HW_H2_CH_HUB_ADR    0x03
> +#define NETXEN_HW_H3_CH_HUB_ADR    0x01
> +#define NETXEN_HW_H4_CH_HUB_ADR    0x06
> +#define NETXEN_HW_H5_CH_HUB_ADR    0x07
> +#define NETXEN_HW_H6_CH_HUB_ADR    0x08
> +
> +/*  Hub 0 */
> +#define NETXEN_HW_MN_CRB_AGT_ADR    0x15
> +#define NETXEN_HW_MS_CRB_AGT_ADR    0x25
> +
> +/*  Hub 1 */
> +#define NETXEN_HW_PS_CRB_AGT_ADR    0x73
> +#define NETXEN_HW_SS_CRB_AGT_ADR    0x20
> +#define NETXEN_HW_RPMX3_CRB_AGT_ADR    0x0b
> +#define NETXEN_HW_QMS_CRB_AGT_ADR    0x00
> +#define NETXEN_HW_SQGS0_CRB_AGT_ADR    0x01
> +#define NETXEN_HW_SQGS1_CRB_AGT_ADR    0x02
> +#define NETXEN_HW_SQGS2_CRB_AGT_ADR    0x03
> +#define NETXEN_HW_SQGS3_CRB_AGT_ADR    0x04
> +#define NETXEN_HW_C2C0_CRB_AGT_ADR    0x58
> +#define NETXEN_HW_C2C1_CRB_AGT_ADR    0x59
> +#define NETXEN_HW_C2C2_CRB_AGT_ADR    0x5a
> +#define NETXEN_HW_RPMX2_CRB_AGT_ADR    0x0a
> +#define NETXEN_HW_RPMX4_CRB_AGT_ADR    0x0c
> +#define NETXEN_HW_RPMX7_CRB_AGT_ADR    0x0f
> +#define NETXEN_HW_RPMX9_CRB_AGT_ADR    0x12
> +#define NETXEN_HW_SMB_CRB_AGT_ADR    0x18


overall, enums are preferred over #define.  It provides type info to the 
compiler, provides symbol info to debuggers and similar tools, and other 
benefits.

e.g.

enum {
	NETXEN_HW_RPMX9_CRB_AGT_ADR	= 0x12,
	NETXEN_HW_SMB_CRB_AGT_ADR	= 0x18,
};



> +#define NETXEN_PCI_MAPSIZE    128
> +#define NETXEN_PCI_DDR_NET    (unsigned long)0x00000000
> +#define NETXEN_PCI_QDR_NET    (unsigned long)0x04000000
> +#define NETXEN_PCI_DIRECT_CRB    (unsigned long)0x04400000
> +#define NETXEN_PCI_CAMQM_MAX    (unsigned long)0x04ffffff
> +#define NETXEN_PCI_OCM0        (unsigned long)0x05000000
> +#define NETXEN_PCI_OCM0_MAX    (unsigned long)0x050fffff
> +#define NETXEN_PCI_OCM1        (unsigned long)0x05100000
> +#define NETXEN_PCI_OCM1_MAX    (unsigned long)0x051fffff
> +#define NETXEN_PCI_CRBSPACE    (unsigned long)0x06000000

Use the 'UL' suffix, not a cast



> +struct netxen_pcix_crb_window {
> +    netxen_crbword_t rsvd1:25, addrbit:1,    /* bit 25 of CRB address */
> +     rsvd2:6;
> +};

see bitfields objections in another email

