From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net v4 0/3] xen-netback: synchronisation between core
 driver and netback
Date: Tue, 12 Aug 2014 17:53:46 +0100
Message-ID: <53EA469A.5030008@citrix.com>
References: <1407840488-20026-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24056 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981AbaHLQxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 12:53:50 -0400
In-Reply-To: <1407840488-20026-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/14 11:48, Wei Liu wrote:
> The zero-copy netback has far more interactions with core network driver than
> the old copying backend. One significant thing is that netback now relies on
> a callback from core driver to correctly release resources.
>
> However correct synchronisation between core driver and netback is missing.
> Currently netback relies on a loop to wait for core driver to release
> resources. This is proven not enough and erroneous recently, partly due to code
> structure, partly due to missing synchronisation. Short-live domains like
> OpenMirage unikernels can easily trigger race in backend, rendering backend
> unresponsive.
>
> This patch series aims to slove this issue by introducing proper
> synchronisation between core driver and netback.
>
> Wei.
>
> Chagges in v4:
> * avoid using wait queue
> * remove dedicated loop for netif_napi_del
> * remove unnecessary check on callback
>
> Change in v3: improve commit message in patch 1
>
> Change in v2: fix Zoltan's email address in commit message
>
>
> Wei Liu (3):
>    xen-netback: move NAPI add/remove calls
>    xen-netback: don't stop dealloc kthread too early
>    xen-netback: remove loop waiting function
>
>   drivers/net/xen-netback/common.h    |    5 ++++
>   drivers/net/xen-netback/interface.c |   56 ++++++++++++++---------------------
>   drivers/net/xen-netback/netback.c   |   26 +++++++++++-----
>   3 files changed, 47 insertions(+), 40 deletions(-)
>

Looks good for me.

Acked-by: Zoltan Kiss <zoltan.kiss@citrix.com>
