From: Glen Turner <gdt@gdt.id.au>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 09:46:07 +1030
Message-ID: <1200438967.5860.11.camel@andromache>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net>
	 <478D226E.1050209@gmail.com>
	 <20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:50255 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751123AbYAOXUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 18:20:21 -0500
In-Reply-To: <20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-01-16 at 00:46 +0300, slavon@bigtelecom.ru wrote:

> But i have above 45 k classes and qdiscs.... After some time i will  
> need patch to up max qdisc and classes more then 65k (> 0xfffe) =)))
> Also i have very bad TC commands performance then i have more then 10k rules.

In contrast a "brand name" router will support 4 to 16 queues
per (sub-)interface.  Your large number of queues exceeds
expectations.

What are you trying to do?  You may be better off inventing a
new qdisc to meet your need (eg, to do per-IP traffic shaping
or, less complexly, a traffic shaping based on the value of mark
which might offend DiffServ purists) or have, say, 1000 output
rates based on a marking and use the ipset feature of Netfilter
to set the mark.  Using 1000 rates gives an error of 0.1% which
is unlikely to be noticed by your customers given the larger
effects of shaping on TCP performance but is beneath the
level where you are noticing performance issues.

