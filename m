From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: prevent out of bound accesses
Date: Thu, 30 Jun 2016 15:24:59 +0200
Message-ID: <57751DAB.9080900@cumulusnetworks.com>
References: <1467291379.11238.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36352 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbcF3NZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 09:25:03 -0400
Received: by mail-wm0-f44.google.com with SMTP id f126so221779609wma.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 06:25:02 -0700 (PDT)
In-Reply-To: <1467291379.11238.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/06/16 14:56, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> ether_addr_equal_64bits() requires some care about its arguments,
> namely that 8 bytes might be read, even if last 2 byte values are not
> used.
> 
> KASan detected a violation with null_mac_addr and lacpdu_mcast_addr
> in bond_3ad.c
> 
> Fixes: 815117adaf5b ("bonding: use ether_addr_equal_unaligned for bond addr compare")
> Fixes: bb54e58929f3 ("bonding: Verify RX LACPDU has proper dest mac-addr")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  drivers/net/bonding/bond_3ad.c |   11 +++++++----
>  drivers/net/bonding/bond_alb.c |    3 ---
>  include/net/bonding.h          |    7 ++++++-
>  3 files changed, 13 insertions(+), 8 deletions(-)
> 

Good catch,
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
