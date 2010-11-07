From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] firewire: net: rate-limit log spam at transmit failure
Date: Sun, 07 Nov 2010 13:03:08 +0100
Message-ID: <4CD6957C.5030504@s5r6.in-berlin.de>
References: <tkrat.01ca17fba0508ae0@s5r6.in-berlin.de>	 <tkrat.1b9925fa1d199c23@s5r6.in-berlin.de>	 <tkrat.18b9f67ac78dcbea@s5r6.in-berlin.de>	 <tkrat.276aeae22ec60090@s5r6.in-berlin.de>	 <1289100404.3277.28.camel@maxim-laptop> <1289100737.3277.32.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:41822 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab0KGMDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 07:03:19 -0500
In-Reply-To: <1289100737.3277.32.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Levitsky wrote:
> I have here my own hack to set the transaction timeout,

You can use firecontrol to set it on-the-fly.  To set it on node ffc2 i.e. the
node with phy ID 2, and controller 1 (i.e. libraw1394 "port" 1):
# echo "w . 2 0xfffff0000018 4 3" | firecontrol 1

This sets the whole-seconds part to 3, which gives you 3.1 seconds timeout if
the fractional part at 0xfffff000001c is still at its default value of 0.1
seconds, i.e. 800 << 19 (subsecond part in units of (1/8000)s shifted by 19).

# { echo "r . 2 0xfffff0000018 4"; echo "r . 2 0xfffff000001c 4"; } |
firecontrol 1

displays the current register value on node ffc2 at port 1.  Type "help" in
firecontrol for more available firecontrol commands.
-- 
Stefan Richter
-=====-==-=- =-== --===
http://arcgraph.de/sr/
