From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv4 gro receive IHL
Date: Tue, 23 Oct 2012 08:01:34 +0200
Message-ID: <1350972094.8609.1420.camel@edumazet-glaptop>
References: <20121022.234606.1841113825492366676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45254 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab2JWGBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:01:39 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1235947eek.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 23:01:37 -0700 (PDT)
In-Reply-To: <20121022.234606.1841113825492366676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 23:46 -0400, David Miller wrote:
> Eric why do we force the length field to '5' in the ip_fast_csum()
> call of inet_gro_receive()?  This happened as part of commit
> a9e050f4e7f9d36afe0dcc0bddba864ee442715e ("net: tcp: GRO should be ECN
> friendly")
> 
> This will cause the checksum check to fail for any IPV4 header with
> options.
> 
> If that's intended, the way to do this is to reject by checking the
> iph->ihl value, rather than doing so obscurely via the checksum call.
> --

Hi David

GRO on IPv4 only supports ihl = 5, this is tested in :

if (*(u8 *)iph != 0x45)
    goto out_unlock;


I also was planning to add some code to ip_fast_csum(addr, X) to have a
fast path (no conditional jump) for the case where X is the constant 5


Thanks !
