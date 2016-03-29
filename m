From: Jesse Gross <jesse@kernel.org>
Subject: Re: [net PATCH] gro: Allow tunnel stacking in the case of FOU/GUE
Date: Mon, 28 Mar 2016 19:54:06 -0700
Message-ID: <CAEh+42h4rMJUnGTXE8JM3VW2g1dW7qDkQkK2kMWw3UU+TKbHKA@mail.gmail.com>
References: <20160328235613.26269.26291.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:41193 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750943AbcC2CyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 22:54:24 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 31100200C1
	for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 02:54:23 +0000 (UTC)
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F341720225
	for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 02:54:21 +0000 (UTC)
Received: by mail-qg0-f52.google.com with SMTP id u110so2097432qge.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:54:21 -0700 (PDT)
In-Reply-To: <20160328235613.26269.26291.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 4:58 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch should fix the issues seen with a recent fix to prevent
> tunnel-in-tunnel frames from being generated with GRO.  The fix itself is
> correct for now as long as we do not add any devices that support
> NETIF_F_GSO_GRE_CSUM.  When such a device is added it could have the
> potential to mess things up due to the fact that the outer transport header
> points to the outer UDP header and not the GRE header as would be expected.
>
> Fixes: fac8e0f579695 ("tunnels: Don't apply GRO to multiple layers of encapsulation.")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>
> This should allow us to keep the fix that Jesse added without breaking the
> 3 cases that Tom called out in terms of FOU/GUE.
>
> Additional work will be needed in net-next as we probably need to make it
> so that offloads work correctly when we get around to supporting
> NETIF_F_GSO_GRE_CSUM.

Thanks, this looks like a reasonable fix to me. I agree that there is
more that can be done in the future to improve things but this should
restore GRO while still avoiding possible issues.
