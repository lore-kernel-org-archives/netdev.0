From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] ifb and ppp
Date: Fri, 21 Sep 2007 13:56:31 +0200
Message-ID: <46F3B16F.1060909@trash.net>
References: <200709191417.43768.mail@frithjof-hammer.de>	 <46F25F9A.7010007@trash.net> <1190294388.4734.6.camel@localhost>	 <200709201600.15202.mail@frithjof-hammer.de>  <46F2910E.9040900@trash.net> <1190373789.4261.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Frithjof Hammer <mail@frithjof-hammer.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62682 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbXIUMEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:04:20 -0400
In-Reply-To: <1190373789.4261.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2007-20-09 at 17:26 +0200, Patrick McHardy wrote:
> 
>> I don't see a good solution for this that
>>allows to keep the iptables rules, I'd suggest to switch to ematches.
> 
> 
> One approach could be to use ipt action:
> 
> -------------------
> tc filter add dev ppp0 parent ffff: protocol ip u32 match u32/ematch
> some match flowid 1:1 action ipt -j mark --set-mark 1
> ..
> ...
> ....
> iptables here to use the marks ...


This doesn't help much since he uses the iptables marks for
classification on the ifb device, so he might as well just
classify directly using u32. I think it would be nice to
have an ematch equivalent to the ipt action for matches.
Should be pretty easy to write (slightly above 60 seconds
according to the documentation :)).
