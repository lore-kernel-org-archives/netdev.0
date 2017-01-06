From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] dccp: fix option range in dccp_parse_options()
Date: Fri, 06 Jan 2017 09:14:30 -0800
Message-ID: <1483722870.9712.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483721009.9712.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33058 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752570AbdAFROb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 12:14:31 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so77158pgd.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 09:14:31 -0800 (PST)
In-Reply-To: <1483721009.9712.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-06 at 08:43 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> dccp_parse_options() improperly parses 12 or 16 bytes in excess,
> because it forgets to subtract DCCP header len.
> 
> This causes various issues, since these 12/16 bytes are part of the
> payload and this might not even be present in skb->head, as
> dccp_invalid_packet() only pulled everything but payload.
> 
> KASAN complains since we might access uninitialized data.

Scratch that.

Never send a patch before first coffee in the morning ;)
