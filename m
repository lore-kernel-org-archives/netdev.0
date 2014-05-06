From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Is 3.18 patch "The tcp: TSO packets automatic sizing" will cause
 to Troughput drop when enable NO_HZ_IDEL or HIGH_RES_TIMERS ?
Date: Tue, 6 May 2014 12:48:27 -0400
Message-ID: <CADVnQy=1WdUT1xHX04uBQtROwOYDZF6idw1Qx2o2DM13kWWjFQ@mail.gmail.com>
References: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: V JobNickname <workofv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:45647 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaEFQs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:48:29 -0400
Received: by mail-we0-f178.google.com with SMTP id u56so8539748wes.9
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:48:28 -0700 (PDT)
In-Reply-To: <CANHbGWs=oQBDVVZc8h5wX0WY+PRbQfCqiv5FrF1tH29QGiRndA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2014 at 12:17 PM, V JobNickname <workofv@gmail.com> wrote:
> More detail trace, the first commit of 3.10.18, tcp: TSO packets
> automatic sizing, cause to this issue.
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/diff/?id=5e25ba5003ee5de0ba2be56bfd54d16d4b1b028d

To provide another data point, it would be interesting to know what
performance you see with v3.15-rc4. Linux 3.15 has the following
patch:

 740b0f1841f6  tcp: switch rtt estimations to usec resolution

That patch switches tcp_update_pacing_rate() to use microsecond RTTs
for its calculation. That may help things in your case. (As Eric says,
more details would help.)

> I don't know why this TSO patch affect my network since the network
> driver doesn't enable NETIF_F_TSO.

Keep in mind that anytime the Linux TCP code or commit descriptions
talk about "TSO", the same applies to GSO. Is GSO enabled for your
device?

neal
