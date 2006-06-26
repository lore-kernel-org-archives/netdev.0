From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Tue, 27 Jun 2006 00:49:30 +0200
Message-ID: <44A0647A.1070209@trash.net>
References: <20060626145446.948105000@postel.suug.ch> <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net> <20060626.104654.98552111.davem@davemloft.net> <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:14018 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S933314AbWFZWtc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 18:49:32 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <44A05FE0.7070203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> All my testing (quite a lot) in this area so far suggested that queueing
> at ingress doesn't work and is actually counter-productive. It gets
> worse with increasing signal propagation delays (signal in this case
> means congestion indications). I actually wish I never introduced
> the stupid IMQ device, it raises false hope and a lot of people seem
> to fall for it.

Small clarification: with queueing at ingress I mean queueing after
the bottleneck. It might work if you introduce a virtual bottleneck,
but in that case in my experience the bandwidth limit you have to use
is dependant on the number of TCP flows, so usually you can't specify
a limit that will always work, and its wasteful if there is a smaller
number of TCP flows. The reason why you would do it, limiting or
prioritizing incoming traffic on the _real_ bottleneck, is not
achievable of course. Also noteworthy is that policers don't behave
any better, and any other schemes I've tried (I also experienced a
lot of with TCP rate control) have similar or related problems.

