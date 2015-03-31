From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Mon, 30 Mar 2015 21:48:36 -0700
Message-ID: <1427777316.25985.168.camel@edumazet-glaptop2.roam.corp.google.com>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
	 <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426852239.25985.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b25a45de2cb43bbcfcaa84634d74533e.squirrel@www.codeaurora.org>
	 <744bbefe8859bf667eafc0de02729078.squirrel@www.codeaurora.org>
	 <1427149742.25985.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <49d5ac3130df29059f167a0401754c67.squirrel@www.codeaurora.org>
	 <6ef597cb521f6c9adf48562c72677415.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34890 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbbCaEsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 00:48:40 -0400
Received: by pddn5 with SMTP id n5so8168658pdd.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 21:48:40 -0700 (PDT)
In-Reply-To: <6ef597cb521f6c9adf48562c72677415.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-30 at 23:49 +0000, subashab@codeaurora.org wrote:

> Hi Eric
> 
> While the original issue of data stall due to missing IPI is no longer
> seen with netif_rx_ni(), the scenario of rps cpu online in [1 -
> get_rps_cpus] but offline in [2 - net_rps_action_and_irq_enable] could
> still occur. Using your patch, triggering an IPI on an offline cpu in [2]
> leads to a crash on my arch.
> 
> I would like to know your thoughts on how to fix this race. Could the
> patch which I had initially proposed help here. Alternatively, is it
> correct to reset NAPI state and increment dropped sd count if an offline
> CPU is detected in [2].
> 


Listen, I would rather disable RPS on your arch, instead of messing with
it.

Reset NAPI state as you did is in direct violation of the rules.

Only cpu owning the bit is allowed to reset it.
