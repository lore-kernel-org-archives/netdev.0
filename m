From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH net-next] liquidio: optimize reads from Octeon PCI console
Date: Thu, 29 Dec 2016 17:48:26 -0800
Message-ID: <20161230014826.GA6085@felix.cavium.com>
References: <20161230010447.GA6015@felix.cavium.com>
 <MWHPR07MB2943250F549EEF0D697C5E54F36A0@MWHPR07MB2943.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: "Chickles, Derek" <Derek.Chickles@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0049.outbound.protection.outlook.com ([104.47.34.49]:35456
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751039AbcL3CWW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 21:22:22 -0500
Content-Disposition: inline
In-Reply-To: <MWHPR07MB2943250F549EEF0D697C5E54F36A0@MWHPR07MB2943.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chickles, Derek <Derek.Chickles@cavium.com> wrote on Thu [2016-Dec-29 17:42:34 -0800]:
> >  #ifdef __BIG_ENDIAN_BITFIELD
> >  static inline void
> > @@ -96,6 +96,25 @@ __octeon_pci_rw_core_mem(struct octeon_device
> > *oct, u64 addr,
> >  	u32 copy_len = 0, index_reg_val = 0;
> >  	unsigned long flags;
> >  	u8 __iomem *mapped_addr;
> > +	u64 static_mapping_base;
> > +
> > +	static_mapping_base = oct->console_nb_info.dram_region_base;
> > +
> 
> Does this work when there are multiple cards?

Yes, it works when there are multiple cards.
