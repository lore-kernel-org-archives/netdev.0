From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] skge: fix broken driver
Date: Fri, 20 Sep 2013 23:38:54 +0200
Message-ID: <20130920213854.GA19732@electric-eye.fr.zoreil.com>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
 <20130919.135628.1201613770803318193.davem@davemloft.net>
 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
 <1379614608.2331.0.camel@ThinkPad-X230.localdomain>
 <alpine.LRH.2.02.1309191427420.15640@file01.intranet.prod.int.rdu2.redhat.com>
 <20130919213218.GA31672@electric-eye.fr.zoreil.com>
 <alpine.LRH.2.02.1309201030420.30821@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Igor Gnatenko <i.gnatenko.brain@gmail.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54656 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab3ITVjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 17:39:07 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1309201030420.30821@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikulas Patocka <mpatocka@redhat.com> :
> On Thu, 19 Sep 2013, Francois Romieu wrote:
[...]
> > Both patches don't behave exactly the same wrt pci_unmap_single.
[...]
> I see, my patch passes a wrong value to pci_unmap_single. So I made this 
> change to make it pass the correct value. Do you agree with this patch ?

Yes. I did not report it. Igor did.

You may "struct skge_element ee = *e;" and save a line. Who cares about
the extra copy when netdev_alloc_skb_ip_align fails ?

Something less ugly for the longer term
- use netdev_alloc_skb_ip_align in skge_rx_fill
- have skge_rx_setup return previouly stored sk_buff * - NULL if it was so -
  and ERR_PTR when it fails for whatever reason
- move netdev_alloc_skb_ip_align into skge_rx_setup
- pci_unmap in skge_rx_setup
- profit

Or isolate the struct sk_buff * + DEFINE_DMA_ part in skge_element then
save it as a whole in skge_rx_setup before initializing a new one as a
(netdev_alloc_skb_ip_align + pci_map).

Does someone volunteer to write it for net-next once the fix has been
merged and later pulled into net-next ?

-- 
Ueimor
