From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/2] net: Set sk_txhash from a random number
Date: Wed, 29 Jul 2015 22:02:30 +0200
Message-ID: <20150729200230.GB26146@pox.localdomain>
References: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
 <1438124526-2129341-2-git-send-email-tom@herbertland.com>
 <20150729091333.GB13113@pox.localdomain>
 <1438162146.20182.74.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150729095416.GC13113@pox.localdomain>
 <CALx6S35Y+XsHHKNDkYzyYgbNH3tv4po-ix3GAhrpawbgg2LBXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33887 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbbG2UCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 16:02:33 -0400
Received: by wibud3 with SMTP id ud3so234383250wib.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 13:02:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35Y+XsHHKNDkYzyYgbNH3tv4po-ix3GAhrpawbgg2LBXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/15 at 08:58am, Tom Herbert wrote:
> The salient property of both sk_txhash and skb->hash is that they
> provide a uniform distribution over flows. It is incorrect to assume
> that either of these immutable during the lifetime of a flow, so yes
> this means that packets of a flow may go to different receive queues
> when hashes change. SO_REUSEPORT is a process in the receive path but
> uses ehashfn over the ports. But even with SO_REUSEPORT we provide no
> guarantee that packets of a "flow" will always hit the same socket,
> the hashing is not consistent when new reuseport sockets are added or
> removed-- this is actually a long standing issue with SO_REUSEPORT in
> the TCP case since it is possible to orphan connections in SYN-RECV. I
> believe Eric was working toward fixing that, so maybe in the future we
> can use skb->hash if it is a savings.

Thanks for the explanation. I have no objections to the changes then.
