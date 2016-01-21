From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Thu, 21 Jan 2016 03:27:34 +0100
Message-ID: <20160121022734.GC29853@pox.localdomain>
References: <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
 <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
 <20160120013128.GA6326@pox.localdomain>
 <56A01BBF.1010301@hpe.com>
 <1453334825.1223.332.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEh+42g4Zk6WVRwQDLi_fT3wWmQDEdPRA-aRidov1YD5MpYx6A@mail.gmail.com>
 <1453336495.1223.341.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@kernel.org>, John <john.phillips5@hpe.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37412 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755197AbcAUC1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:27:38 -0500
Received: by mail-wm0-f44.google.com with SMTP id n5so58339347wmn.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:27:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1453336495.1223.341.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/16 at 04:34pm, Eric Dumazet wrote:
> On Wed, 2016-01-20 at 16:19 -0800, Jesse Gross wrote:
> 
> > I have a patch that implements the comparison between dsts. For
> > packets without a dst, there isn't really a cost and if we do have a
> > dst then GRO is still a benefit. So it seems like it is worth doing,
> > even if it is more expensive than is ideal.
> 
> You guys really want to kill GRO performance.
> 
> Really the aggregation should happen at the first layer (ethernet
> device), instead of doing it after tunnel decap.
> 
> This is already done for GRE, IPIP, SIT, ...
> 
> GRO having to access metadata looks wrong, if you think about trying to
> do the same function in hardware (offload)

If I understand Jesse correctly then the added cost is only for
metadata enabled packets. Though I agree, what's the benefit of
doing GRO after decap?

It seems like it's way too late and we've already paid the cost
by going through the stack for each outer header packet.
