From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] sctp: Fix sk_ack_backlog wrap-around problem
Date: Thu, 12 Jun 2014 10:04:55 +0200
Message-ID: <53995F27.4050308@redhat.com>
References: <1402541616-15117-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Xufeng Zhang <xufeng.zhang@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389AbaFLIGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 04:06:09 -0400
In-Reply-To: <1402541616-15117-1-git-send-email-xufeng.zhang@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2014 04:53 AM, Xufeng Zhang wrote:
> Consider the scenario:
> For a TCP-style socket, while processing the COOKIE_ECHO chunk in
> sctp_sf_do_5_1D_ce(), after it has passed a series of sanity check,
> a new association would be created in sctp_unpack_cookie(), but afterwards,
> some processing maybe failed, and sctp_association_free() will be called to
> free the previously allocated association, in sctp_association_free(),
> sk_ack_backlog value is decremented for this socket, since the initial
> value for sk_ack_backlog is 0, after the decrement, it will be 65535,
> a wrap-around problem happens, and if we want to establish new associations
> afterward in the same socket, ABORT would be triggered since sctp deem the
> accept queue as full.
> Fix this issue by only decrementing sk_ack_backlog for associations in
> the endpoint's list.
>
> Fix-suggested-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>

Looks good to me, thanks. This also needs to go to -stable.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
