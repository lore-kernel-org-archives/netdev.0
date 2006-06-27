From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Tue, 27 Jun 2006 12:03:09 +0200
Message-ID: <20060627100309.GU1376@postel.suug.ch>
References: <20060626.104654.98552111.davem@davemloft.net> <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net> <44A0647A.1070209@trash.net> <20060626145446.948105000@postel.suug.ch> <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net> <20060626.104654.98552111.davem@davemloft.net> <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49347 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932588AbWF0KCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 06:02:48 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44A0647A.1070209@trash.net> <44A05FE0.7070203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-06-27 00:29
> Doesn't sound too silly (actually quite nifty in my opinion),
> but I'm not sure I understand correctly, binding to ifb doesn't
> work since it changes both skb->dev and skb->input_dev.

I don't understand this concern. So far the mirred action
updates iif but that can be made configurable.

* Patrick McHardy <kaber@trash.net> 2006-06-27 00:49
> Small clarification: with queueing at ingress I mean queueing after
> the bottleneck. It might work if you introduce a virtual bottleneck,
> but in that case in my experience the bandwidth limit you have to use
> is dependant on the number of TCP flows, so usually you can't specify
> a limit that will always work, and its wasteful if there is a smaller
> number of TCP flows. The reason why you would do it, limiting or
> prioritizing incoming traffic on the _real_ bottleneck, is not
> achievable of course. Also noteworthy is that policers don't behave
> any better, and any other schemes I've tried (I also experienced a
> lot of with TCP rate control) have similar or related problems.

My interest in ingress queueing is mainly on a local delivery
case where skb->tstamp can be modified to control tcp metrics.
I agree that a lot of wrong expectations have developed with
IMQ and similiar devices.

