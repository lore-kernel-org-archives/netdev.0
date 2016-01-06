From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 05 Jan 2016 19:21:11 -0800
Message-ID: <1452050471.8255.161.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
	 <568C5336.9090907@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33304 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbcAFDVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 22:21:13 -0500
Received: by mail-pf0-f182.google.com with SMTP id q63so194933462pfb.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 19:21:12 -0800 (PST)
In-Reply-To: <568C5336.9090907@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-06 at 00:35 +0100, Hannes Frederic Sowa wrote:

> 
> Tom, did you have a look if it makes sense to add a second carry 
> addition train with the adcx instruction, which does not signal carry 
> via the carry flag but with the overflow flag? This instruction should 
> not have any dependencies with  the adc instructions and could help the 
> CPU to parallelize the code even more (increased instructions per cycle).

I guess adcx would (possibly) bring improvements for large areas, but
for this case the bottleneck is to bring data from memory.

Note this topic was discussed 2 years ago and no conclusive action was
taken.

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg529610.html
