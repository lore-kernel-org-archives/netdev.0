From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Reset skb to network header in neigh_hh_output
Date: Sat, 08 Oct 2016 06:10:56 +0900
Message-ID: <1475874656.28155.268.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1579f7f0f4f.114457ec828613.4349884782265574217@abahmed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Abdelrhman Ahmed <ab@abahmed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34999 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757421AbcJGVLC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 17:11:02 -0400
In-Reply-To: <1579f7f0f4f.114457ec828613.4349884782265574217@abahmed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-10-07 at 16:14 +0200, Abdelrhman Ahmed wrote:
> When hardware header is added without using cached one, neigh_resolve_output
> and neigh_connected_output reset skb to network header before adding it.
> When cached one is used, neigh_hh_output does not reset the skb to network
> header.
> 
> The fix is to reset skb to network header before adding cached hardware header
> to keep the behavior consistent in all cases.

What is the issue you want to fix exactly ?

Please describe the use case.

I highly suggest you take a look at commit

e1f165032c8bade3a6bdf546f8faf61fda4dd01c
("net: Fix skb_under_panic oops in neigh_resolve_output")

Otherwise, your fix is in fact adding a critical bug.
