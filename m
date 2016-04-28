From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: make TCP preemptible
Date: Thu, 28 Apr 2016 11:04:12 -0700
Message-ID: <1461866652.5535.115.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
	 <20160428172320.GA83199@ast-mbp.thefacebook.com>
	 <1461865270.5535.109.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160428175154.GA83737@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33131 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbcD1SEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 14:04:15 -0400
Received: by mail-pa0-f54.google.com with SMTP id zm5so38786558pac.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 11:04:14 -0700 (PDT)
In-Reply-To: <20160428175154.GA83737@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 10:51 -0700, Alexei Starovoitov wrote:

> got it. It applies to both v4 and v6, right?

You mean IPv6 ?

Well, you know, I decided to skip IPv6 and go to IPv8 anyway ;) 

Yes, these changes apply for both IPv4 and IPv6 in the meantime.


> that would be awesome. I think map/reduce type jobs typically
> do large sendmsg, so it should help p99 latency.

Note that it should even help to send faster, since the ACK packets or
TCP Small Queue handlers are blocked until the sendmsg() was complete.

ACK packets usually open the window for more sends.

Many applications are using a loop and multiple sendmsg( ) with ~64KB
chunks to work around these latency issues.
