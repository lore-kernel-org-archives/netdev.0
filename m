From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen terminating condition
Date: Wed, 29 Aug 2007 18:32:15 +0200
Message-ID: <18133.40847.166882.838333@robur.slu.se>
References: <20070829044352.GA4133@ludhiana>
	<1188395183.4274.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Mandeep Singh Baines <mandeep.baines@gmail.com>,
	davem@davemloft.net, rick.jones2@hp.com, msb@google.com,
	netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, venza@brownhat.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:58961 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbXH2QhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 12:37:20 -0400
In-Reply-To: <1188395183.4274.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:
 > On Tue, 2007-28-08 at 21:43 -0700, Mandeep Singh Baines wrote:

 > I think its a good thing pktgen caught this; i am unsure however if it
 > is doing the right thing. Hoping Robert would respond.
 > One thing pktgen could do is restrict the amount of outstanding buffers
 > by using accounting the way sockets do - this at least wont stop
 > progress as it did in your case.

 Hello,

 Yes it's synchronization issue... the test is over and we have sent 
 all pkts to the device but pktgen cannot free the skb for it still 
 has refcounts. 

 IMO must drivers have provisions to handle situation like. I'll 
 guess we can discuss last-resort timer if it should be us, ms 
 or possibly seconds but shouldn't need ping to make this happen. 
 If so we probably have a ICMP packet sitting there waiting instead.  

 Cheers
					--ro
