From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Tue, 5 May 2015 01:04:14 +0200
Message-ID: <20150504230414.GB8279@pox.localdomain>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
 <20150504155639.GA14367@Alexeis-MBP.westell.com>
 <20150504161956.GK22481@breakpoint.cc>
 <5547AA9C.3030300@mojatatu.com>
 <20150504174358.GN22481@breakpoint.cc>
 <5547BEC4.4090400@mojatatu.com>
 <20150504185941.GA17061@breakpoint.cc>
 <20150504200506.GA14604@Alexeis-MacBook-Pro.local>
 <20150504222131.GA4348@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37928 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbEDXER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:04:17 -0400
Received: by wiun10 with SMTP id n10so126300929wiu.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 16:04:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150504222131.GA4348@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/15 at 12:21am, Pablo Neira Ayuso wrote:
> On Mon, May 04, 2015 at 01:05:08PM -0700, Alexei Starovoitov wrote:
> > [...] TC critical path becomes slower with extra dereference and
> > indirect jump.
> 
> You complained on the performance impact of the initial generic hook
> infrastructure that allows qdisc ingress and nft to co-exist, fair
> enough.
> 
> I came back with an even more simple hook infrastructure, to address
> performance concerns, and you indicate that an *extra dereference and
> indirect jump* makes this slowier and that both cannot co-exist with
> this.
> 
> Well, any kind of hook generalization will need at least those minimal
> changes. And that allows us to move code that belongs to sch_ingress.
> That got embedded into net/core/dev.c because at the time this code
> was made when there was no RCU around.

Does anything speak against a separate hook with a static key?
