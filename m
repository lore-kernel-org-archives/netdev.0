From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] tcp: TCP_NOTSENT_LOWAT socket option
Date: Tue, 23 Jul 2013 09:48:18 -0700
Message-ID: <1374598098.3449.39.camel@edumazet-glaptop>
References: <1374550027.4990.141.camel@edumazet-glaptop>
	 <51EEA089.3040904@hp.com> <1374594244.3449.13.camel@edumazet-glaptop>
	 <51EEAD54.2040603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:43025 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932764Ab3GWQsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:48:21 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro2so8649287pbb.41
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 09:48:20 -0700 (PDT)
In-Reply-To: <51EEAD54.2040603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 09:20 -0700, Rick Jones wrote:

> Right - I am questioning whether it is worth the CPU increase.

There is no cpu increase for common workloads, and hosts can save GB of
precious memory thanks to this patch.

There is a cpu increase only for 'netperf' kind of program, relying on
blocking sendmsg() and using one thread per socket, _if_ and only _if_
they set a crazy notsent_lowat value.

Remember I forced nobody to do that. Its like forcing SO_SNDBUF with one
byte, and SO_RCVBUF with one byte, and expecting good line rate
performance !

This patch changes the threshold to get the 'socket is writeable'
POLLOUT event, and avoid filling socket write queues with too many
packets.

Like all thresholds, it has to be properly used.
