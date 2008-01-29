From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Tue, 29 Jan 2008 11:57:33 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com>
References: <20080129184726.GA29300@gateway.home>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Erik Mouw" <mouw@nl.linux.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1059 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765772AbYA2UF2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 15:05:28 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080129184726.GA29300@gateway.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've just started to use 2.6.24 on my home firewall (before 
> it was running 2.6.24-rc2 for about 65 days) and I noticed a 
> couple of error messages I've never seen before:
> 
> Jan 29 07:50:54 gateway kernel: BUG eth1 code -5 qlen 0 Jan 
> 29 08:28:30 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> 08:57:30 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> 09:44:04 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> 10:01:35 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> 10:01:35 gateway last message repeated 2 times Jan 29 
> 10:16:48 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> 10:16:48 gateway last message repeated 2 times Jan 29 
> 10:45:48 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> 10:45:48 gateway last message repeated 2 times Jan 29 
> 11:10:01 gateway kernel: BUG eth1 code -5 qlen 0 Jan 29 
> 11:10:02 gateway last message repeated 9 times
> 
> The message seems to be coming from the qdisc_restart() in 
> net/sched/sch_generic.c which was changed with commit 
> 5f1a485d5905aa641f33009019b3699076666a4c .
> 
> The NIC is an IBM EtherJet cardbus card using the xircom_cb driver:

Are you using any specific qdisc, or just the default pfifo_fast?  Have
you done any specific tuning on your qdisc as well?  The default qlen
seems to have been changed.

Basically your queue is being overrun, and with the current checks in
the kernel in the stack, it's allowing the skb into the driver.  I've
known about this issue, and I'm hesitant to push a patch to re-add the
netif_queue_stopped() check into qdisc_restart().  I'd rather push a
one-time patch to the drivers that interacts with
netif_stop_subqueue(netdev, 0), so we can completely decouple the single
queue from the netdev.

I'd say you can somewhat ignore the messages for now.  But there is work
to be done here, and it's obvious I need to do this sooner than later.
Please let me know about the qdisc parameters though when you get a
chance.

Thanks,

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
