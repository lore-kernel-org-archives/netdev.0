From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network stream fairness
Date: Sun, 29 Nov 2015 09:40:12 -0800
Message-ID: <1448818812.24696.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5640BEAC.10404@axis.com>
	 <1447084258.17135.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5640C15E.805@axis.com>
	 <1447085271.17135.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <564F3D3D.7050004@axis.com>
	 <1448043414.22599.287.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5655ADC7.3040606@axis.com>
	 <1448459372.22599.324.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151129024120.GA6522@lnxniklass.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35257 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbbK2RkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 12:40:15 -0500
Received: by pacej9 with SMTP id ej9so159797337pac.2
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 09:40:14 -0800 (PST)
In-Reply-To: <20151129024120.GA6522@lnxniklass.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> If I didn't know that though, my expectations would be that the
> Fair Queue packet scheduler would behave just like its name says, fair. :P
> 

Only if the flows have same characteristics. This cannot be ensured for
hours long flows. This should be obvious.

If one flow is not trying to push enough, it will loose its round in the
Round Robin scheduler, because no packet is sitting in the packet
scheduler for this flow.

A simple slowdown, cause by a packet drop, or scheduler artifact on the
sender or receiver can make one flow steal whole bandwidth, even when FQ
is in the picture.

I have no idea why you are expecting multiple TCP flows being fair.
There is absolutely nothing in TCP protocol to ensure this.


In short, fq_codel or fq are not doing what you think they do.

If you want fair flows, you MUST pace them say at 40Mbits each.

The fact that one 'patch' slightly changes the condition for unfairness
to start is absolutely irrelevant.
