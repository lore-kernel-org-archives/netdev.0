From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] ifb and ppp
Date: Thu, 20 Sep 2007 17:26:06 +0200
Message-ID: <46F2910E.9040900@trash.net>
References: <200709191417.43768.mail@frithjof-hammer.de> <46F25F9A.7010007@trash.net> <1190294388.4734.6.camel@localhost> <200709201600.15202.mail@frithjof-hammer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, lartc@mailman.ds9a.nl,
	Linux Netdev List <netdev@vger.kernel.org>
To: Frithjof Hammer <mail@frithjof-hammer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40205 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbXITPde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 11:33:34 -0400
In-Reply-To: <200709201600.15202.mail@frithjof-hammer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frithjof Hammer wrote:
>>Sorry, I didnt follow the thread - what is the goal to be achieved with
>>the setup?
> 
> 
> A simple ingress shaping on ppp0 (PPPOE DSL line). I want to replace my old 
> imq ingress shaper in favor of ifb. My former script used iptables marks  to 
> classify the packets. My iptables marks are getting set, as like before with 
> imq. But tc seems not to recognize them: It only uses the default class.
> 
> So i run tcpdump -i ifb0  and discovered that the packets seems to be still 
> encapsulated on ifb0. I suppose this is why my iptables stuff is not working.


Thats actually a completely different problem. Unlike with imq, packets
are delivered to ifb *before* they pass through iptables. So at that
time they're not marked. I don't see a good solution for this that
allows to keep the iptables rules, I'd suggest to switch to ematches.
