From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netem: Segment GSO packets on enqueue.
Date: Tue, 26 Apr 2016 13:19:15 -0700
Message-ID: <1461701955.5535.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
	 <1461696598.5535.35.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160426190026.GB12788@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32931 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbcDZUTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:19:17 -0400
Received: by mail-pa0-f45.google.com with SMTP id zm5so11732913pac.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 13:19:17 -0700 (PDT)
In-Reply-To: <20160426190026.GB12788@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-26 at 15:00 -0400, Neil Horman wrote:
> I can understand that, but that raises two questions in my mind:
> 
> 1)  Doesn't that make all the statistical manipulation for netem wrong?  That is
> to say, if netem drops 5% of packets, and it happens to drop a GSO packet, its
> actually dropping several, instead of the single one required.


Please take a look at tbf_segment(), where you can find a proper way to
handle this.

Note that for the case q->corrupt is 0, we definitely do not want to
segment TSO packets.

> 2) How are you getting netem to work with GSO at all?  The warning is triggered
> for me on every GSO packet, which I think would impact throughput :)

I mostly use netem to add delays and drops.
I never had this bug, since q->corrupt = 0
