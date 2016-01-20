From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel memory leak in bnx2x driver with vxlan tunnel
Date: Tue, 19 Jan 2016 16:17:47 -0800
Message-ID: <1453249067.1223.300.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5697D833.5010506@hpe.com>
	 <CAEh+42jMi2EP3LFvUTXiO+WKkGSOuZ5e8X748QFipZUBk8uz9g@mail.gmail.com>
	 <1453243654.1223.290.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42iikonSmsLu5f3UyQCPge0rmUmNu15ggvpkPdv9gqKQ=g@mail.gmail.com>
	 <1453247464.1223.297.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John <john.phillips5@hpe.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, david.roth@hpe.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32809 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414AbcATARt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 19:17:49 -0500
Received: by mail-pf0-f171.google.com with SMTP id e65so184370976pfe.0
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 16:17:49 -0800 (PST)
In-Reply-To: <CAEh+42hAHUeXaDYJbyocigyXADcOfTYKMiMAzBmScG8JFht4JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-19 at 16:00 -0800, Jesse Gross wrote:

> Oh, I wasn't disagreeing that there is a problem. I was just trying to
> point out the conceptual root of the problem rather than the
> individual instances in different tunnels implementations.
> 
> In any case, I think we can solve this by calling
> skb_release_head_state() in napi_skb_finish() and switching early
> demux to use skb_valid_dst().

Yes, but it will also have to call skb_dst_drop() or risk a leak of
prior one.

So what is the purpose of having a dst if we need to drop it ?

Adding code in GRO would be fine if someone explains me the purpose of
doing apparently useless work.

(refcounting on dst is not exactly free)
