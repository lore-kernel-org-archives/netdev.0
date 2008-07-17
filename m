From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Thu, 17 Jul 2008 16:02:20 +0200
Message-ID: <487F50EC.80008@trash.net>
References: <20080717.051726.226040470.davem@davemloft.net>	 <487F4327.1000107@trash.net> <1216301732.4726.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57027 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336AbYGQOCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 10:02:24 -0400
In-Reply-To: <1216301732.4726.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Thu, 2008-17-07 at 15:03 +0200, Patrick McHardy wrote:
> 
>> Actions are also visible
>> globally, so this might still be a problem, not sure though since
>> they don't refer to their parent (haven't thought about it much yet).
> 
> Actions are fine because they are intended to be globaly shared.
> [i.e A classifier on ethx with qdiscA:Y (in/egress) can share an action
> with  classifer on  ethy with qdiscB:Z (eg/ingress)].

Yes, in that case its not a problem. The case where it behaves
differently than now is when only a single reference exists.

> Like you i need to digest the patches to understand the impact on the
> rest but one thing i did notice was the last patch (replacement of
> pfifo_fast):
> prioritization based on TOS/DSCP (setsockopt) would no longer work, some
> user space code may suffer (routing daemons likely). One suggestion to
> fix it is to load pfifo qdisc (which does what fifo_fast is attempting)
> for drivers that are h/ware multiq capable.

That would perform priorization within each qdisc, the individual
qdiscs would still be transmitted using seperate HW queues though.

