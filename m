From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Tue, 18 Nov 2014 21:39:25 -0800
Message-ID: <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wwgwork@gmail.com, netdev@vger.kernel.org
To: Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:58583 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaKSFj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 00:39:27 -0500
Received: by mail-ig0-f181.google.com with SMTP id l13so418606iga.14
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 21:39:26 -0800 (PST)
In-Reply-To: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-19 at 13:18 +0800, Wengang Wang wrote:
> When last slave of a bonding master is removed, the bonding then does not work.
> When packet_snd is called against with a master net_device, it accesses
> header_ops. In case the header_ops is not valid any longer(say ipoib module
> unloaded), it will then access an invalid memory address.
> This patch try to fix this issue by clearing header_ops when last slave
> detached.
> 
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> ---
>  drivers/net/bonding/bond_main.c | 1 +
>  1 file changed, 1 insertion(+)

It seems you basically ignored my feedback.



Some code is doing :

[A] if (dev->header_ops) {
    ...
[B]    dev->header_ops->XXX()



Nothing prevents you doing the clear after [A] , and before [B]
