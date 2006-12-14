From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] drivers/net/loopback.c: convert to module_init()
Date: Wed, 13 Dec 2006 16:21:17 -0800 (PST)
Message-ID: <20061213.162117.125896771.davem@davemloft.net>
References: <20061213231848.GY8693@postel.suug.ch>
	<20061213233128.GD3629@stusta.de>
	<20061213154125.5e118ba5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, tgraf@suug.ch, viro@ftp.linux.org.uk,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751817AbWLNAVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 19:21:19 -0500
To: shemminger@osdl.org
In-Reply-To: <20061213154125.5e118ba5@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 13 Dec 2006 15:41:25 -0800

> But what if other network device is not a module. We want loopback
> to be first. so it needs to be before other device_initcall's

There is zero evidence that loopback must be first.

I was not able to provide any after my study of the code last night,
and I haven't seen any concrete proof shown today either.

You mentioned "the dst code" relies on ifindex==1, what exactly do you
mean by that?  Give specific code examples instead of ambiguous and
non-specific references.

And this claim doesn't make any sense, because anyone who looks at
drivers/net/Makefile can see that several drivers are linked in way
before Space.o, and thus when built statically would today end up in
the device list way before the loopback driver.  So it can't be
"broken" by Adrian's change, since it's already not putting loopback
first and we can prove this! :-)
