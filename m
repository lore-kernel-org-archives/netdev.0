From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] liquidio: store the L4 hash of rx packets in
 skb
Date: Mon, 09 Jan 2017 10:51:06 -0800
Message-ID: <1483987866.21472.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170107005542.GA16278@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33707 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423108AbdAISvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:51:08 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so7882199pgd.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:51:08 -0800 (PST)
In-Reply-To: <20170107005542.GA16278@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-06 at 16:55 -0800, Felix Manlunas wrote:
> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> Store the L4 hash of received packets in the skb; the hash is computed in
> the NIC firmware.
...

>  
> +		if (rh->r_dh.has_hash) {
> +			u32 hash = be32_to_cpu(*(u32 *)(skb->data + r_dh_off));

sparse should complain on this line, right ?

make C=2 CF=-D__CHECK_ENDIAN__ M=drivers/net/ethernet/cavium
