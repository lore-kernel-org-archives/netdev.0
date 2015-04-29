From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Wed, 29 Apr 2015 15:56:51 -0700
Message-ID: <1430348211.3711.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
	 <1430273488-8403-2-git-send-email-ast@plumgrid.com>
	 <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5541535E.1060908@plumgrid.com>
	 <1430345993.3711.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55415D6B.7070009@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36134 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbbD2W4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:56:53 -0400
Received: by iebrs15 with SMTP id rs15so54618448ieb.3
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:56:53 -0700 (PDT)
In-Reply-To: <55415D6B.7070009@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 15:38 -0700, Alexei Starovoitov wrote:

> I'm not making and not suggesting any new rules.
> ip_rcv is doing this skb_share_check() not because of pktgen rx,
> but because there can be taps and deliver_skb() as you said.
> gro has a different interface and this pktgen cannot benchmark it.
> rps/rfs is not benchmarkable but this approach either.
> To me this is all fine. I'm not trying to do a universal
> benchmarking tool. This one is dumb and simple and primarily
> oriented to benchmark changes to netif_receive_skb and ingress
> qdisc only. I'm not suggesting to use it everywhere.
> I already mentioned in cover letter:
> "The profile dump looks as expected for RX of UDP packets
> without local socket except presence of __skb_clone."
> Clearly I'm not suggesting to use pktgen rx to optimize IP stack
> and not suggesting at all that stack should assume users!=1
> when skb hits netif_receive_skb. Today at the beginning of
> netif_receive_skb we know that users==1 without checking.
> I'm not changing that assumption.
> Just like pktgen xmit path is cheating little bit while
> benchmarking TX, I'm cheating a little bit with users!=1 on RX.

Look, you don't have to write all this, just fix the bug I mentioned to
you about RPS / RFS. (details in Documentation/networking/scaling.txt )

Simply read the code in enqueue_to_backlog(), this obviously needs to
own skb->next/prev

So pktgen in RX mode MUST deliver skb with skb->users = 1, there is no
way around it.
