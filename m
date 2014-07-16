From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv4] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 16 Jul 2014 23:52:03 +0200
Message-ID: <1405547523.10255.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405534236-26542-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:60285 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043AbaGPVwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:52:08 -0400
Received: by mail-we0-f170.google.com with SMTP id w62so1583495wes.29
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 14:52:07 -0700 (PDT)
In-Reply-To: <1405534236-26542-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-16 at 11:10 -0700, Mahesh Bandewar wrote:
> In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
> group are selected based on the hash distribution. This does not
> exclude dead links which are part of the bond. Also if there is a
> temporary link event which brings down the interface, packets
> hashed on that interface would be dropped too.
> 
> This patch fixes these issues and distributes flows across the
> UP links only. Also the array construction of links which are
> capable of sending packets happen in the control path leaving
> only link-selection during the data-path.
> 
> One possible side effect of this is - at a link event; all
> flows will be shuffled to get good distribution. But impact of
> this should be minimum with the assumption that a member or
> members of the bond group are not available is a very temporary
> situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---

OK, this one seems fine, thanks ;)

Signed-off-by: Eric Dumazet <edumazet@google.com>

This is for net-next tree.
