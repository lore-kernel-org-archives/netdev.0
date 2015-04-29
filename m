From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Wed, 29 Apr 2015 16:28:05 -0700
Message-ID: <55416905.7070308@plumgrid.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>	 <1430273488-8403-2-git-send-email-ast@plumgrid.com>	 <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>	 <5541535E.1060908@plumgrid.com>	 <1430345993.3711.59.camel@edumazet-glaptop2.roam.corp.google.com>	 <55415D6B.7070009@plumgrid.com> <1430348211.3711.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33617 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbbD2X2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:28:08 -0400
Received: by igbpi8 with SMTP id pi8so726124igb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 16:28:07 -0700 (PDT)
In-Reply-To: <1430348211.3711.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/15 3:56 PM, Eric Dumazet wrote:
>
> So pktgen in RX mode MUST deliver skb with skb->users = 1, there is no
> way around it.

if I only knew how to do it...
The cost of continuously allocating skbs is way higher than
netif_receive_skb itself. Such benchmarking tool would measure the
speed of skb alloc/free instead of speed of netif_receive_skb.
Are you suggesting to pre-allocate 10s of millions of skbs and
then feed them in one go? The profile will be dominated by
cache misses in the first few lines of __netif_receive_skb_core()
where it accesses skb->dev,data,head. Doesn't sound too useful either.
Other thoughts?
