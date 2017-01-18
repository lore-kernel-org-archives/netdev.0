From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: fec: Fixed panic problem with non-tso
Date: Tue, 17 Jan 2017 21:02:18 -0800
Message-ID: <1484715738.13165.95.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170117.154512.612465430064515761.davem@davemloft.net>
         <20170118041140.15371-1-ashiduka@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org
To: Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33121 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751116AbdARFCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 00:02:21 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so338653pgd.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 21:02:21 -0800 (PST)
In-Reply-To: <20170118041140.15371-1-ashiduka@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-18 at 13:11 +0900, Yuusuke Ashiduka wrote:
> If highmem and 2GB or more of memory are valid,
> "this_frag-> page.p" indicates the highmem area,
> so the result of page_address() is NULL and panic occurs.
> 
> This commit fixes this by using the skb_frag_dma_map() helper,
> which takes care of mapping the skb fragment properly. Additionally,
> the type of mapping is now tracked, so it can be unmapped using
> dma_unmap_page or dma_unmap_single when appropriate.


I would prefer we fix the root cause, instead of tweaking all legacy
drivers out there :/
