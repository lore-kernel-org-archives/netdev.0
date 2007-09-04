From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
	condition
Date: Tue, 04 Sep 2007 09:03:56 -0400
Message-ID: <1188911036.4483.10.camel@localhost>
References: <1188643644-77674666b52f8e4df330ca0982689109@brownhat.org>
	 <20070904032036.GA11153@ludhiana>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniele Venzano <venza@brownhat.org>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: Mandeep Singh Baines <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:41251 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbXIDNED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 09:04:03 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1164145rvb
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2007 06:04:02 -0700 (PDT)
In-Reply-To: <20070904032036.GA11153@ludhiana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-03-09 at 20:20 -0700, Mandeep Singh Baines wrote:

> I didn't see much saving in interrupts on my machine (too fast, I guess). 

You could try the idea suggested by Dave earlier and just turn interupts
for every nth packet. That should cut down the numbers.

> I did see a significant boost to tx performance by optimizing start_xmit: more
> than double pps in pktgen.

148Kpps on a slow piece of hardware aint bad - Good Stuff. I wonder how
much CPU is being abused.

If you wanna go one extra mile (separate future patch): get rid of that
tx lock and use netif_tx_lock on the interupt path. Look at some sane
driver like tg3 for reference.

cheers,
jamal

