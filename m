From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix slow start after idle vs TSO/GSO
Date: Fri, 21 Aug 2015 09:27:11 -0700
Message-ID: <1440174431.6610.79.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440090487.6610.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQyms7VoJm32dY5qiUf4A332mZTHXZXKUkkOm5BS0f77GDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33673 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbHUQ1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 12:27:13 -0400
Received: by pacgz8 with SMTP id gz8so39449pac.0
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 09:27:13 -0700 (PDT)
In-Reply-To: <CADVnQyms7VoJm32dY5qiUf4A332mZTHXZXKUkkOm5BS0f77GDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-21 at 11:10 -0400, Neal Cardwell wrote:

> Very nice catch, and this fix seems like a definite improvement.
> 
> One potential issue is that the connection can restart from idle not
> just because new data has been written (which this patch addresses),
> but also because the receive window opens and so now packets can be
> sent again. The old version of the code implicitly fired the restart
> code path in the "receive window opens" case as well, since it fired
> every time new data was sent. We might want to check if we need to
> call tcp_cwnd_restart() in tcp_ack_update_window(), next to the call
> for tcp_fast_path_check()?

Excellent, I wrote a 2nd packetdrill test to exercise this path, will
submit a v2 soon.

Thanks Neal
