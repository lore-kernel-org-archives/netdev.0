From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: call tcp_replace_ts_recent() from tcp_ack()
Date: Fri, 19 Apr 2013 10:01:59 -0700
Message-ID: <1366390919.16391.25.camel@edumazet-glaptop>
References: <1366384390.16391.17.camel@edumazet-glaptop>
	 <CADVnQymOBoJ9687qn9-fQCXdMcuaP23-bP-Y1ZS0aoYqCdaFVg@mail.gmail.com>
	 <1366390793.16391.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51149 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab3DSRCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 13:02:02 -0400
Received: by mail-pa0-f46.google.com with SMTP id lb1so2374589pab.33
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 10:02:01 -0700 (PDT)
In-Reply-To: <1366390793.16391.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 09:59 -0700, Eric Dumazet wrote:
> On Fri, 2013-04-19 at 12:33 -0400, Neal Cardwell wrote:
> 
> > This patch looks good. But AFAICT the other call site for
> > tcp_replace_ts_recent() has the same bug, which can be fixed in the
> > same way: tcp_rcv_state_process() seems to fall through the big switch
> > statement down to its call to tcp_replace_ts_recent() even in some
> > cases where tcp_ack() already decided the ACK was unacceptable.
> 
> I was not sure of the second call site, and was willing to discuss this
> with you and Yuchung.
> 
> Are you comfortable this is net material and not net-next ? (We are
> talking of states other than ESTABLISHED)

The other concern was about conflict with the prior net-next patch (tcp:
remove one indentation level in tcp_rcv_state_process())
