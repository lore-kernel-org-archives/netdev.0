From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 08/13] net: ethernet: aquantia: PCI operations
Date: Fri, 13 Jan 2017 17:48:52 -0800
Message-ID: <4f02834a-7770-fffd-24fe-81d1e41a2df8@gmail.com>
References: <cover.1484283610.git.vomlehn@texas.net>
 <2889e8e87b8b89945f34e57a7f8ca253f204de47.1484283610.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35668 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdANBsz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 20:48:55 -0500
Received: by mail-it0-f67.google.com with SMTP id 203so6844960ith.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 17:48:55 -0800 (PST)
In-Reply-To: <2889e8e87b8b89945f34e57a7f8ca253f204de47.1484283610.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 09:02 PM, Alexander Loktionov wrote:
> From: David VomLehn <vomlehn@texas.net>
> 
> Add functions that handle the PCI bus interface.
> 
> Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
> Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
> Signed-off-by: David M. VomLehn <vomlehn@texas.net>
> ---

> +	/*enable interrupts */
> +#if AQ_CFG_FORCE_LEGACY_INT
> +	self->irq_type = AQ_IRQ_LEGACY;
> +#else
> +	err = pci_enable_msix(self->pdev, self->msix_entry,
> +			      self->aq_hw_caps.msix_irqs);

You should really try MSI(x) first and fallback to leagcy PCI INT# if
you cannot succeed, asking for a driver rebuild to switch between these
behaviors may not be an option for most people (a module parameter may
be an option but is usually not such a great idea).
-- 
Florian
