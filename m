From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at kernel/softirq.c:159
 _local_bh_enable_ip+0x35/0x71()
Date: Thu, 23 Feb 2012 15:08:46 -0500 (EST)
Message-ID: <20120223.150846.2241731542881529513.davem@davemloft.net>
References: <1422860.157191329872584374.JavaMail.weblogic@epml01>
	<20120223104237.GA2127@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, jongman.heo@samsung.com,
	netdev@vger.kernel.org, scottjg@vmware.com, pv-drivers@vmware.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756806Ab2BWUJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 15:09:54 -0500
In-Reply-To: <20120223104237.GA2127@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 23 Feb 2012 11:42:37 +0100

> As far as I understand it you can not claim a fake transport layer header
> size for udp and blindly check the available buffer size through
> pskb_may_pull later. With a 32 bits HIGHMEM guest config (yuck...) it ends
> up enabling bh within a network device start_xmit context.

Right, lying about the transport header size is going to give you nothing
but trouble, you absolutely cannot do this or networking breaks, and your
transmit handler doesn't run in a context where you can legally "fix"
things up.

We recently fixed even IPoIB in this regard.
