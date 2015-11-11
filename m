From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Tue, 10 Nov 2015 22:19:29 -0800
Message-ID: <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	 <877fnc7i0i.fsf@bytheb.org>
	 <CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
	 <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35781 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbbKKGTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 01:19:32 -0500
Received: by pasz6 with SMTP id z6so22544716pas.2
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 22:19:32 -0800 (PST)
In-Reply-To: <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-10 at 21:41 -0800, Tom Herbert wrote:
> Tolga, are you still planning to respin this patch (when tree opens?)

I was planning to add an union on skc_tx_queue_mapping and
sk_max_ack_backlog, so that adding a check on sk_max_ack_backlog in
listener lookup would not add an additional cache line miss.

This would remove false sharing because sk_ack_backlog is often dirtied
when a socket is added into accept queue.
