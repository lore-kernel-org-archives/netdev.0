From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] net: mvneta: increase the 64-bit rx/tx stats out of
 the hot path
Date: Sun, 12 Jan 2014 16:49:52 -0800
Message-ID: <1389574192.31367.194.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
	 <1389519069-1619-2-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:39771 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbaAMAtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 19:49:53 -0500
Received: by mail-pd0-f178.google.com with SMTP id v10so249946pde.23
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 16:49:53 -0800 (PST)
In-Reply-To: <1389519069-1619-2-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 10:31 +0100, Willy Tarreau wrote:
> Better count packets and bytes in the stack and on 32 bit then
> accumulate them at the end for once. This saves two memory writes
> and two memory barriers per packet. The incoming packet rate was
> increased by 4.7% on the Openblocks AX3 thanks to this.
> 
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)


Reviewed-by: Eric Dumazet <edumazet@google.com>

Note that with such a cost, one has to wonder why we keep 64bit stats
for this NIC on 32bit hosts...
