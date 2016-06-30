From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH v2 net] bonding: prevent out of bound accesses
Date: Thu, 30 Jun 2016 16:43:51 +0200
Message-ID: <57753027.7040006@cumulusnetworks.com>
References: <1467291379.11238.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467296021.11238.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33078 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122AbcF3OwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 10:52:07 -0400
Received: by mail-wm0-f43.google.com with SMTP id r190so4871502wmr.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 07:51:54 -0700 (PDT)
In-Reply-To: <1467296021.11238.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/06/16 16:13, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> ether_addr_equal_64bits() requires some care about its arguments,
> namely that 8 bytes might be read, even if last 2 byte values are not
> used.
> 
> KASan detected a violation with null_mac_addr and lacpdu_mcast_addr
> in bond_3ad.c
> 
> Same problem with mac_bcast[] and mac_v6_allmcast[] in bond_alb.c :
> Although the 8-byte alignment was there, KASan would detect out
> of bound accesses.
> 
> Fixes: 815117adaf5b ("bonding: use ether_addr_equal_unaligned for bond addr compare")
> Fixes: bb54e58929f3 ("bonding: Verify RX LACPDU has proper dest mac-addr")
> Fixes: 885a136c52a8 ("bonding: use compare_ether_addr_64bits() in ALB")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  drivers/net/bonding/bond_3ad.c |   11 +++++++----
>  drivers/net/bonding/bond_alb.c |    7 ++-----
>  include/net/bonding.h          |    7 ++++++-
>  3 files changed, 15 insertions(+), 10 deletions(-)
> 

+CC bonding maintainers

For v2,
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
