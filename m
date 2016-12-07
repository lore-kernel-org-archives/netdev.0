From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: under rx pressure, try to condense skbs
Date: Wed, 07 Dec 2016 11:31:42 -0800
Message-ID: <1481139102.4930.65.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36569 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932550AbcLGTco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 14:32:44 -0500
Received: by mail-pf0-f195.google.com with SMTP id c4so21023199pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 11:32:43 -0800 (PST)
In-Reply-To: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 09:19 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

> This patch gave me about 5 % increase in throughput in my tests.
> 

BTW, this reduces the gap with GRO being on or off for me :

mlx4 drivers has a copybreak feature when GRO is off :

Packets below 256 bytes are simply copied into a linear skb
 ( done in mlx4_en_rx_skb() )
