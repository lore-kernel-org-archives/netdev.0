From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: don't extend RTO on failed loss probe
 attempts
Date: Sat, 18 Jul 2015 07:27:45 +0200
Message-ID: <1437197265.1026.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437168172-24201-1-git-send-email-ycheng@google.com>
	 <1437168172-24201-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:35583 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbbGRF1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 01:27:50 -0400
Received: by wgav7 with SMTP id v7so29638462wga.2
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 22:27:49 -0700 (PDT)
In-Reply-To: <1437168172-24201-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-17 at 14:22 -0700, Yuchung Cheng wrote:
> If TLP was unable to send a probe, it extended the RTO to
> now + icsk_rto. But extending the RTO makes little sense
> if no TLP probe went out. With this commit, instead of
> extending the RTO we re-arm it relative to the transmit time
> of the write queue head.

But what was the reason the probe could not be sent ?

If it is local congestion or memory allocation error, it does make sense
to not add fuel to the fire.
