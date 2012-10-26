From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Fri, 26 Oct 2012 07:32:09 +0200
Message-ID: <1351229529.6537.284.camel@edumazet-glaptop>
References: <1351212356-11964-1-git-send-email-subramanian.vijay@gmail.com>
	 <1351227971.6537.278.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliot Hughes <enh@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:49421 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804Ab2JZFc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 01:32:27 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so86985wib.1
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 22:32:26 -0700 (PDT)
In-Reply-To: <1351227971.6537.278.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 07:06 +0200, Eric Dumazet wrote:

> About earlier patch, this would break :
> 
> tcp_abort_on_overflow - BOOLEAN
...
> And even if tcp_abort_on_overflow is TRUE, earlier patch would break
> some ability to have a momentary burst of SYN packets above the listen()
> backlog.

So instead of sending SYNACK immediately, we could try to defer it a
bit.

But before adding yet another trick, we should evaluate if this is
really needed.

The timer wheel we currently use on the listener socket limits us
because of the granularity of the timer (one single timer for all
requests)
