From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: delay address promotion check until last request
 in message
Date: Mon, 09 Nov 2015 07:31:38 +0900 (KST)
Message-ID: <20151109.073138.1861688515066155518.davem@davemloft.net>
References: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
	<alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
	<20151108215641.GA16147@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbbKHWbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 17:31:42 -0500
In-Reply-To: <20151108215641.GA16147@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Sun, 8 Nov 2015 16:56:41 -0500

> All I'm doing is, in effect masking the promote_secondaries sysctl
> for an interface doing a flush operation.

Packets and other entities not controlled by RTNL can see an inconsistent
state: no primary address on the interface.

You can argue that this happened already but usually the window is tiny.

For the case you are optimizing for, the window is now several seconds
long.  That's not really something we can do.
