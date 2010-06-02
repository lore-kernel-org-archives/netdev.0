From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bnx2: Fix hang during rmmod bnx2.
Date: Wed, 02 Jun 2010 02:27:27 -0700 (PDT)
Message-ID: <20100602.022727.267973204.davem@davemloft.net>
References: <1275440736-18058-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755138Ab0FBJ1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:27:17 -0400
In-Reply-To: <1275440736-18058-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 1 Jun 2010 18:05:36 -0700

> The regression is caused by:
> 
> commit 4327ba435a56ada13eedf3eb332e583c7a0586a9
>     bnx2: Fix netpoll crash.
> 
> If ->open() and ->close() are called multiple times, the same napi structs
> will be added to dev->napi_list multiple times, corrupting the dev->napi_list.
> This causes free_netdev() to hang during rmmod.
> 
> We fix this by calling netif_napi_del() during ->close().
> 
> Also, bnx2_init_napi() must not be in the __devinit section since it is
> called by ->open().
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

Applied, thanks!
