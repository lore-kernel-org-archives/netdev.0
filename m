From: "Mandeep Baines" <mandeep.baines@gmail.com>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating condition
Date: Tue, 4 Sep 2007 10:21:08 -0700
Message-ID: <535ddc6b0709041021y4f280aa2t829c46a33b19bb16@mail.gmail.com>
References: <1188643644-77674666b52f8e4df330ca0982689109@brownhat.org>
	 <20070904032036.GA11153@ludhiana> <1188911036.4483.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Daniele Venzano" <venza@brownhat.org>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:29112 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754863AbXIDRVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 13:21:10 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1703294fkz
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2007 10:21:09 -0700 (PDT)
In-Reply-To: <1188911036.4483.10.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/4/07, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2007-03-09 at 20:20 -0700, Mandeep Singh Baines wrote:
>
> > I didn't see much saving in interrupts on my machine (too fast, I guess).
>
> You could try the idea suggested by Dave earlier and just turn interupts
> for every nth packet. That should cut down the numbers.
>

I wanted to do that but I couldn't figure out how to free the last skb
if it happened to be a transmit that didn't generate a tx completion
interrupt.

Let's say I interrupt every 4th packet.I've already sent packets 0 to
4. Now I send packets 5 and 6. I can't figure out how to ensure that
the skb's for these packets get freed in a deterministic amount of
time if there is no interrupt? They will get freed when packet 8 gets
transmitted but there is no upper bound on when that will happen.

Maybe I could create a tx skb cleanup timer that I kickoff in
hard_start_xmit(). Every call to hard_start_xmit would reset the
timer. I could try this for a future patch. Not sure if the extra code
would cost me more than I get back in savings.

> > I did see a significant boost to tx performance by optimizing start_xmit: more
> > than double pps in pktgen.
>
> 148Kpps on a slow piece of hardware aint bad - Good Stuff. I wonder how
> much CPU is being abused.
>
> If you wanna go one extra mile (separate future patch): get rid of that
> tx lock and use netif_tx_lock on the interupt path. Look at some sane
> driver like tg3 for reference.
>

Cool. I'll check out the tg3.
