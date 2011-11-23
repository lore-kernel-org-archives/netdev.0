From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 03/10] net: Add netdev interfaces recording
 send/compl
Date: Wed, 23 Nov 2011 18:58:12 -0500 (EST)
Message-ID: <20111123.185812.1721878183759040757.davem@davemloft.net>
References: <alpine.DEB.2.00.1111222139560.14623@pokey.mtv.corp.google.com>
	<20111123094614.36560215@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab1KWX6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 18:58:14 -0500
In-Reply-To: <20111123094614.36560215@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 23 Nov 2011 09:46:14 -0800

> Since all the drivers that you show do this for one packet at a time,
> why bother with a packets arguement to netdev_sent_queue()?

They batch the completion, that's why f.e. e1000e's changes keep track of
pkts_compl and bytes_compl, and then pass that in at the end of the TX
completion processing so that we only invoke these interfaces once per
run instead of once per packet.
