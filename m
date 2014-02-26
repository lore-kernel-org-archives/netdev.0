From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Wed, 26 Feb 2014 09:57:39 -0500
Message-ID: <CADVnQyn4Zszpc2eTg0BkJZY0+Y-LBcPHTPTjVS2o8_zZTX31jg@mail.gmail.com>
References: <20140218181205.GA7780@kau.se>
	<CAK6E8=ekVXA9JrajwmJk88bUKcJSi=T5+SFXs0VoG5iQkWBcRw@mail.gmail.com>
	<20140219105041.GA9981@kau.se>
	<CAK6E8=cQVr_J6YQGT6z0H3R41tBCpD=1BToqYxzYis4wKxqhew@mail.gmail.com>
	<C8E05F6E-62B4-4B5A-8DE1-3F166F2705CA@kau.se>
	<CAK6E8=e9LiA32SZ0_jD7woGeJYxzixsw3hQxjZvgyoqpoJSeyg@mail.gmail.com>
	<CAK6E8=c0JVRjUHRuLBrH0nfbKcK818C0h2tkBeWydP67-osumQ@mail.gmail.com>
	<D6FBF93A-8057-497F-A39E-DF6211999DC1@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:52585 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaBZPEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 10:04:47 -0500
Received: by mail-ee0-f50.google.com with SMTP id t10so600716eei.37
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 07:04:46 -0800 (PST)
In-Reply-To: <D6FBF93A-8057-497F-A39E-DF6211999DC1@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 4:50 AM, Per Hurtig <per.hurtig@kau.se> wrote:
> Also, as your setup includes TLP we only have the RTO restart over TLP gain to start
> with.

My gut says the next thing to try is applying the "RTO restart" idea
to the scheduling of the TLP probe (scheduling the TLP probe for
write_queue_head_skb->when + tlp_timeout). Doing an RTO earlier can be
a very bad thing, due to reseting the cwnd to 1. But doing a TLP
earlier does not have much downside, and could have significant
latency savings (though maybe Nandita already tried this at some
point)...

neal
