From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Wed, 20 Jan 2016 16:34:55 -0800
Message-ID: <1453336495.1223.341.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5697D833.5010506@hpe.com>
	 <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
	 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
	 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
	 <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42iRs8RPATfj7P+ADUjFV3nTBMiEU3AXVe5vY9GMDbKKDQ@mail.gmail.com>
	 <20160120013128.GA6326@pox.localdomain> <56A01BBF.1010301@hpe.com>
	 <1453334825.1223.332.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42g4Zk6WVRwQDLi_fT3wWmQDEdPRA-aRidov1YD5MpYx6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John <john.phillips5@hpe.com>, Thomas Graf <tgraf@suug.ch>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35009 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbcAUAe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 19:34:57 -0500
Received: by mail-pf0-f177.google.com with SMTP id 65so13217752pff.2
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 16:34:57 -0800 (PST)
In-Reply-To: <CAEh+42g4Zk6WVRwQDLi_fT3wWmQDEdPRA-aRidov1YD5MpYx6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-20 at 16:19 -0800, Jesse Gross wrote:

> I have a patch that implements the comparison between dsts. For
> packets without a dst, there isn't really a cost and if we do have a
> dst then GRO is still a benefit. So it seems like it is worth doing,
> even if it is more expensive than is ideal.

You guys really want to kill GRO performance.

Really the aggregation should happen at the first layer (ethernet
device), instead of doing it after tunnel decap.

This is already done for GRE, IPIP, SIT, ...

GRO having to access metadata looks wrong, if you think about trying to
do the same function in hardware (offload)
