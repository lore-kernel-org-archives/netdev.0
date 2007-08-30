From: jamal <hadi@cyberus.ca>
Subject: Re: pktgen terminating condition
Date: Thu, 30 Aug 2007 08:08:40 -0400
Message-ID: <1188475721.22423.35.camel@localhost>
References: <20070829044352.GA4133@ludhiana>
	 <1188395183.4274.19.camel@localhost>
	 <18133.40847.166882.838333@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mandeep Singh Baines <mandeep.baines@gmail.com>,
	davem@davemloft.net, rick.jones2@hp.com, msb@google.com,
	netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, venza@brownhat.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:18928 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbXH3MIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 08:08:46 -0400
Received: by wa-out-1112.google.com with SMTP id v27so573136wah
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 05:08:45 -0700 (PDT)
In-Reply-To: <18133.40847.166882.838333@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-29-08 at 18:32 +0200, Robert Olsson wrote:

>  Yes it's synchronization issue... the test is over and we have sent 
>  all pkts to the device but pktgen cannot free the skb for it still 
>  has refcounts. 

Ok, right.

I was confusing it with another issue where pktgen could send a lot of
packets without waiting for them to be freed; there are some drivers
(10G) which may hold onto 8K skbs. A gazillion ooms start spewing ;-> My
thinking in resolving that was to do something like waht sockets do and
charge pktgen so it doesnt have too many outstanding packets in flight.

>  IMO must drivers have provisions to handle situation like. 

Mandeep was saying he found less than a handful that didnt conform.

> I'll 
>  guess we can discuss last-resort timer if it should be us, ms 
>  or possibly seconds but shouldn't need ping to make this happen. 
>  If so we probably have a ICMP packet sitting there waiting instead.  

I think as long as it doesnt affect throughput calculation (it just adds
to idle time) its fine.

cheers,
jamal

