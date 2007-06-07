From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 17:57:25 -0400
Message-ID: <1181253445.4071.4.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
	 <1181172766.4064.83.camel@localhost>
	 <20070606.165215.38711917.davem@davemloft.net>
	 <20070607004712.GE3304@havoc.gtf.org> <1181219380.4064.55.camel@localhost>
	 <46681E41.6060700@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.242]:6962 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765381AbXFGV5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 17:57:31 -0400
Received: by ag-out-0708.google.com with SMTP id 35so524018aga
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 14:57:31 -0700 (PDT)
In-Reply-To: <46681E41.6060700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 08:03 -0700, Kok, Auke wrote: 
> To prevent against multiple entries bumping head & tail at the same time as well 
> as overwriting the same entries in the tx ring (contention for 
> next_to_watch/next_to_clean)? 

In current code that lock certainly doesnt protect those specifics.
I thought at some point thats what it did; somehow that seems to have
changed - the rx path/tx prunning is protected by tx_queue_lock
I have tested it the patch on smp and it works.

> It may be unlikely but ripping out the tx ring 
> lock might not be a good idea, perhaps after we get rid of LLTX in e1000?

I dont think it matters either way. At the moment, you are _guaranteed_
only one cpu can enter tx path. There may be another CPU, but as long
(as in current code) you dont have any contention between tx and rx, it
seems to be a non-issue.

> to be honest: I'm open for ideas and I'll give it a try, but stuff like this 
> needs to go through some nasty stress testing (multiple clients, long time) 
> before I will consider it seriously, but fortunately that's something I can do.

I empathize but take a closer look; seems mostly useless.
And like i said I have done a quick test with an SMP machine and it
seems to work fine; but your tests will probably be more thorough.

cheers,
jamal

