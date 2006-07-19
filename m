From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 19 Jul 2006 16:54:16 +0200
Message-ID: <44BE4798.6070308@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <1151158431.6716.95.camel@jzny2>	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>	 <44BD56A4.9090002@andyfurniss.entadsl.com> <1153270932.4242.60.camel@ras.pc.brisbane.lube> <44BE44E3.9080100@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Russell Stuart <russell-tcatm@stuart.id.au>, hadi@cyberus.ca,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29943 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964851AbWGSOyS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 10:54:18 -0400
To: lists@andyfurniss.entadsl.com
In-Reply-To: <44BE44E3.9080100@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Furniss wrote:
> Russell Stuart wrote:
> 
>> - As it stands, it doesn't help the qdiscs that use   RTAB.  So unless
>> he proposes to remove RTAB entirely   the ATM patch as it will still
>> have to go in.
> 
> 
> Hmm - I was just looking at the kernel changes to htb. The only
> difference is the len - I am blindly assuming that it does/will return
> the link lengths properly for atm.
> 
> So for atm, qdisc_tx_len(skb) will always return lengths that are
> multiples of 53.
> 
> If nothing else were done we would suffer innacuarcy from the cell_log
> just like eth.
> 
> But no other kernel hack would be needed to do it perfectly - rather
> like we (who patch for atm already) just fill the tc generated rate
> table with what we like, that would be an option.

That is how it should work. If the calculation doesn't fit, lets fix it.

>> The kernel will have to do a shift and a division
>> for each packet, which I assume is permissible.
> 
> 
> I guess that is for others to decide :-) I think Patrick has a point
> about sfq/htb drr, Like you I guess, I thought that alot of extra per
> packet calculations would have got an instant NO.

Its only done once per packet (currently, it might be interesting to
override the length for specific classes and their childs, for example
if you do queueing on eth0 and have an DSL router one hop apart).
The division is gone in my patch btw.
