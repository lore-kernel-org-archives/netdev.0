From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: set SOCK_NOSPACE under memory pressure
Date: Thu, 14 May 2015 20:07:08 -0700
Message-ID: <1431659228.27831.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150506155223.9743A2027@prod-mail-relay06.akamai.com>
	 <20150509.173859.948723291650094235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jbaron@akamai.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38626 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945995AbbEODHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 23:07:10 -0400
Received: by igbhj9 with SMTP id hj9so97471009igb.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 20:07:10 -0700 (PDT)
In-Reply-To: <20150509.173859.948723291650094235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-05-09 at 17:38 -0400, David Miller wrote:
> Applied, thanks a lot for adding so much information to the commit
> message.
> --

When doing more tests with this stuff, I found we could still have
hangs, because a TCP socket can end up having no skb in its write queue.

We need to allow one skb (this can be 2KB) to keep the logic being ACK
driven.
