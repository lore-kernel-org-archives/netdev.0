From: Chris Madden <chris@reflexsecurity.com>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 12:27:21 -0400
Message-ID: <46000B69.8000401@reflexsecurity.com>
References: <45FEEE35.6090606@reflexsecurity.com> <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost> <45FFEC78.2090708@reflexsecurity.com> <45FFF455.80003@trash.net> <45FFF675.8040501@trash.net> <20070320151151.GM521@postel.suug.ch> <45FFFA36.7080404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:46912 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbXCTQ1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 12:27:24 -0400
In-Reply-To: <45FFFA36.7080404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>
> There was a small bug in my patch (broken return value on memory
> allocation failure, not relevant for testing though). I'll push
> the fixed patch to Dave once Chris confirms that it fixes the
> problem he's seeing.
>   
Looks like that may have done it.  I ramped up the traffic on it and did
thousands of inserts/removals and the box seems happy.

I had ing_filter still locking dev->ingress_lock ( instead of the
queue_lock suggestion earlier ).   So while that race may still be in
there, I haven't been able to hit the locking problem.

chris
