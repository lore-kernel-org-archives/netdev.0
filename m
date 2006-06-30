From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sat, 1 Jul 2006 01:45:12 +0200
Message-ID: <20060630234512.GR14627@postel.suug.ch>
References: <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2> <20060630203034.GN14627@postel.suug.ch> <20060630.133348.68039806.davem@davemloft.net> <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch> <1151703097.5270.307.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56513 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932239AbWF3Xow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 19:44:52 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151703097.5270.307.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 17:31
> Better to explain the reason for ifb first:
> ifb exists initially as a replacement for IMQ. 
> 1) qdiscs/policies that are per device as opposed to system wide.
> This now allows for sharing.
> 
> 2) Allows for queueing incoming traffic for shaping instead of
> dropping.
> 
> In other wise, the main use is for multiple devices to redirect to it.
> Main desire is not for it to redirect to any other ifb device or eth
> devices. I actually tried to get it to do that, but run into issues
> of complexity and and came up with decision to drop instead of killing
> the machine.
> Other than that, it can redirect to any other devices - but may still
> not be meaningful.

Last time I'm asking. Why are packets dropped? You mentioned tc_verd
is set to 0 leading to a invalid from verdict. Fact is that the
from verdict is set to a meaningful value again at dev_queue_xmit()
or ing_filter() so ifb_xmit() only sees valid values. tx locks of
individual ifb devices are independant, why would it deadlock? Where
is the packet exactly dropped?

> I have been thinking of Herberts change of qdisc_is_running and this may
> help actually.

Help on what?

