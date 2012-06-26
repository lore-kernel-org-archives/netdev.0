From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Tue, 26 Jun 2012 07:34:31 +0200
Message-ID: <201206260734.33472.hans.schillstrom@ericsson.com>
References: <1340440962.17495.39.camel@edumazet-glaptop> <1340686296.10893.115.camel@edumazet-glaptop> <20120625.215537.169465424900682764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"subramanian.vijay@gmail.com" <subramanian.vijay@gmail.com>,
	"dave.taht@gmail.com" <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ncardwell@google.com" <ncardwell@google.com>,
	"therbert@google.com" <therbert@google.com>,
	"brouer@redhat.com" <brouer@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:57616 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756780Ab2FZFef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 01:34:35 -0400
In-Reply-To: <20120625.215537.169465424900682764.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 June 2012 06:55:37 David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 26 Jun 2012 06:51:36 +0200
> 
> > On Mon, 2012-06-25 at 15:43 -0700, David Miller wrote:
> > 
> >> I don't agree with this change.
> >> 
> >> What is the point in having real classification configuration if
> >> arbitrary places in the network stack are going to override SKB
> >> priority with a fixed priority setting?
> >> 
> >> I bet the person who set listening socket priority really meant it and
> >> does not expect you to override it.
> > 
> > 
> > If I add a test on listener_sk->sk_priority being 0, would you accept
> > the patch ? If classification is done after tcp stack, it wont be hurt
> > by initial skb priority ?
> 
> It's better than your original patch, but it suffers from the same
> fundamental problem.
> 
> No user is going to expect that TCP on it's own has choosen a
> non-default priority and only for some packet types.  It's completely
> unexpected behavior.
> 
> A SYN flood consumes so much more RX work than the TX for the SYNACK's
> ever can.
> 
> So whilst I understand your desire to handle all elements of this kind
> of attack, this one is reaching too far.
> 

This patch didn't give much in gain actually.
The big cycle consumer during a syn attack is SHA sum right now, 
so from that perspective it's better to add aes crypto (by using AES-NI) 
to the syn cookies instead of SHA sum. Even if only newer x86_64 can use it.
