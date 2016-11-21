From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp: avoid one cache line miss in recvmsg()
Date: Mon, 21 Nov 2016 14:05:54 -0800
Message-ID: <1479765954.8455.424.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479518283.8455.312.camel@edumazet-glaptop3.roam.corp.google.com>
         <1479764208.5596.0.camel@redhat.com>
         <1479765680.8455.422.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34107 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754261AbcKUWGN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 17:06:13 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so29239484pgc.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 14:05:56 -0800 (PST)
In-Reply-To: <1479765680.8455.422.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-21 at 14:01 -0800, Eric Dumazet wrote:
> Tested-by: Paolo Abeni <pabeni@redhat.com>
> 
> Thanks Paolo
> 
> Note that udp6_recvmsg() hits the 3rd cache line of skb to access
> skb->protocol :
> 
> is_udp4 = (skb->protocol == htons(ETH_P_IP));
> 
> We might some trick to avoid this cache line miss.

Argh, ignore this.

net-next kernel has this field at offset 0xc0, so all is good (since
this 4th cache line contains other needed fields)
