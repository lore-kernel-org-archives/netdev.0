From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 18:06:13 +0100
Message-ID: <46001485.4030203@trash.net>
References: <45FEEE35.6090606@reflexsecurity.com> <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost> <45FFEC78.2090708@reflexsecurity.com> <45FFF455.80003@trash.net> <45FFF675.8040501@trash.net> <20070320151151.GM521@postel.suug.ch> <45FFFA36.7080404@trash.net> <46000B69.8000401@reflexsecurity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Chris Madden <chris@reflexsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54479 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965494AbXCTRGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 13:06:46 -0400
In-Reply-To: <46000B69.8000401@reflexsecurity.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Madden wrote:
> Patrick McHardy wrote:
> 
>>There was a small bug in my patch (broken return value on memory
>>allocation failure, not relevant for testing though). I'll push
>>the fixed patch to Dave once Chris confirms that it fixes the
>>problem he's seeing.
>>  
> 
> Looks like that may have done it.  I ramped up the traffic on it and did
> thousands of inserts/removals and the box seems happy.


Thanks Chris.

> I had ing_filter still locking dev->ingress_lock ( instead of the
> queue_lock suggestion earlier ).   So while that race may still be in
> there, I haven't been able to hit the locking problem.


I'll push a patch for this as well, we can hopefully go back to using
ingress_lock in 2.6.22.
