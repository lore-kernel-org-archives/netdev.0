From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Fri, 23 Sep 2011 20:55:45 -0400
Message-ID: <1316825745.1865.24.camel@mojatatu>
References: <1316757739.2560.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49605 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972Ab1IXA7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 20:59:22 -0400
Received: by gxk6 with SMTP id 6so3089111gxk.19
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 17:59:21 -0700 (PDT)
In-Reply-To: <1316757739.2560.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-23 at 08:02 +0200, Eric Dumazet wrote:
> While playing with a new ADSL box at home, I discovered that ECN
> blackhole can trigger suboptimal quickack mode on linux : We send one
> ACK for each incoming data frame, without any delay and eventual
> piggyback.
>
> This is because TCP_ECN_check_ce() considers that if no ECT is seen on a
> segment, this is because this segment was a retransmit.

If you have Linux as the sender, that assumption is legit (i.e we never
set ECT on retransmits).

> Refine this heuristic and apply it only if we seen ECT in a previous
> segment, to detect ECN blackhole at IP level.

So  small confusion for me, Eric:
Is theres some middlebox clearing the ECT but allowing the TCP header
ECN flags to be set during SYN echange?  If yes, why would not allowing
quickack help?

cheers,
jamal
