From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Tue, 11 Apr 2017 09:12:28 -0700
Message-ID: <1491927148.10587.58.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
         <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net>
         <58EBE73A.7090202@iogearbox.net>
         <20170410214131.GE4730@C02RW35GFVH8.dhcp.broadcom.net>
         <1491926733.10587.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33540 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752746AbdDKQMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 12:12:30 -0400
In-Reply-To: <1491926733.10587.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 09:05 -0700, Eric Dumazet wrote:

> Some kind of copybreak maybe ?
> 
> perf record -a -g sleep 5
> perf report --stdio
> 
> Copybreak is generally not really useful, and can have downsides.
> 
> Much better to let upper stacks deciding this.
> 
> For example, there is no point doing copy break for TCP ACK packets that
> are going to be consumed immediately.
> 
> There is also no point doing copy break in case the packet will be
> dropped (say by ... XDP ;) )


Yes :

#define BNXT_RX_COPY_THRESH 256

For optimal results, you probably want to remove copybreak.
