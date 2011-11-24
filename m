From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 03/10] net: Add netdev interfaces recording
 send/compl
Date: Wed, 23 Nov 2011 16:03:20 -0800
Message-ID: <20111123160320.76143e3b@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1111222139560.14623@pokey.mtv.corp.google.com>
	<20111123094614.36560215@nehalam.linuxnetplumber.net>
	<20111123.185812.1721878183759040757.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33061 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468Ab1KXADW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 19:03:22 -0500
In-Reply-To: <20111123.185812.1721878183759040757.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Nov 2011 18:58:12 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 23 Nov 2011 09:46:14 -0800
> 
> > Since all the drivers that you show do this for one packet at a time,
> > why bother with a packets arguement to netdev_sent_queue()?
> 
> They batch the completion, that's why f.e. e1000e's changes keep track of
> pkts_compl and bytes_compl, and then pass that in at the end of the TX
> completion processing so that we only invoke these interfaces once per
> run instead of once per packet.

I was referring to the transmit routine, there for netdev_sent_queue()
is always called with one packet.

Many drivers batch packets in completion, and call netdev_completed_queue()
with multiple packets (and bytes).
