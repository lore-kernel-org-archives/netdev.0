From: "Chickles, Derek" <Derek.Chickles@cavium.com>
Subject: RE: [PATCH net-next] liquidio: optimize reads from Octeon PCI console
Date: Fri, 30 Dec 2016 01:42:34 +0000
Message-ID: <MWHPR07MB2943250F549EEF0D697C5E54F36A0@MWHPR07MB2943.namprd07.prod.outlook.com>
References: <20161230010447.GA6015@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: "Manlunas, Felix" <Felix.Manlunas@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0070.outbound.protection.outlook.com ([104.47.34.70]:27658
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751402AbcL3B5D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 20:57:03 -0500
In-Reply-To: <20161230010447.GA6015@felix.cavium.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  #ifdef __BIG_ENDIAN_BITFIELD
>  static inline void
> @@ -96,6 +96,25 @@ __octeon_pci_rw_core_mem(struct octeon_device
> *oct, u64 addr,
>  	u32 copy_len =3D 0, index_reg_val =3D 0;
>  	unsigned long flags;
>  	u8 __iomem *mapped_addr;
> +	u64 static_mapping_base;
> +
> +	static_mapping_base =3D oct->console_nb_info.dram_region_base;
> +

Does this work when there are multiple cards?
=20
