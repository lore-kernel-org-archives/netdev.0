From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Wed, 26 Feb 2014 11:52:49 -0800
Message-ID: <CAB_+Fg6aJ66zp0VUK4r+AxV2icskww+rHsvv05Ug=6tU=Zbyhg@mail.gmail.com>
References: <20140218181205.GA7780@kau.se>
	<CAK6E8=ekVXA9JrajwmJk88bUKcJSi=T5+SFXs0VoG5iQkWBcRw@mail.gmail.com>
	<20140219105041.GA9981@kau.se>
	<CAK6E8=cQVr_J6YQGT6z0H3R41tBCpD=1BToqYxzYis4wKxqhew@mail.gmail.com>
	<C8E05F6E-62B4-4B5A-8DE1-3F166F2705CA@kau.se>
	<CAK6E8=e9LiA32SZ0_jD7woGeJYxzixsw3hQxjZvgyoqpoJSeyg@mail.gmail.com>
	<CAK6E8=c0JVRjUHRuLBrH0nfbKcK818C0h2tkBeWydP67-osumQ@mail.gmail.com>
	<D6FBF93A-8057-497F-A39E-DF6211999DC1@kau.se>
	<CADVnQyn4Zszpc2eTg0BkJZY0+Y-LBcPHTPTjVS2o8_zZTX31jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Per Hurtig <per.hurtig@kau.se>, Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	Andreas Petlund <apetlund@simula.no>,
	Michael Welzl <michawe@ifi.uio.no>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:37016 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbaBZTwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 14:52:49 -0500
Received: by mail-oa0-f50.google.com with SMTP id i11so1390651oag.23
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 11:52:49 -0800 (PST)
In-Reply-To: <CADVnQyn4Zszpc2eTg0BkJZY0+Y-LBcPHTPTjVS2o8_zZTX31jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 6:57 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Wed, Feb 26, 2014 at 4:50 AM, Per Hurtig <per.hurtig@kau.se> wrote:
>> Also, as your setup includes TLP we only have the RTO restart over TLP gain to start
>> with.
>
> My gut says the next thing to try is applying the "RTO restart" idea
> to the scheduling of the TLP probe (scheduling the TLP probe for
> write_queue_head_skb->when + tlp_timeout). Doing an RTO earlier can be
> a very bad thing, due to reseting the cwnd to 1. But doing a TLP
> earlier does not have much downside, and could have significant
> latency savings (though maybe Nandita already tried this at some
> point)...

+1 for applying RTO restart idea to scheduling a TLP. The thinking
with TLP at that time, was to send a probe approximately 1.5RTT after
the last "event" (which could be the transmit of a data packet or
receipt of an ACK). I did not try scheduling at
write_queue_head_skb->when + tlp_timeout, but I think it's worth an
experiment (may increase spurious TLPs by some amount which may be
OK).

Nandita
