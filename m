From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 16 May 2014 06:04:34 -0700
Message-ID: <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:56197 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594AbaEPNEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 09:04:37 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so2543577pad.30
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 06:04:36 -0700 (PDT)
In-Reply-To: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 12:08 +0100, Wei Liu wrote:
> Some workload, such as Redis can generate SKBs which make use of
> compound pages. Netfront doesn't quite like that because it doesn't want
> to send packet that occupies exessive slots to the backend as backend
> might deem it malicious. On the flip side these packets are actually
> legit, the size check at the beginning of xennet_start_xmit ensures that
> packet size is below 64K.
> 
> So we linearize SKB if it occupies too many slots. If the linearization
> fails then the SKB is dropped.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Konrad Wilk <konrad.wilk@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Stefan Bader <stefan.bader@canonical.com>
> Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>  drivers/net/xen-netfront.c |   17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)

This is likely to fail on typical host.

What about adding a smart helper trying to aggregate consecutive
smallest fragments into a single frag ?

This would be needed for bnx2x for example as well.
