From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 01:21:46 +0200
Message-ID: <453FF18A.6000107@trash.net>
References: <20061025110843.0cbd18a7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65515 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422766AbWJYXVu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 19:21:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061025110843.0cbd18a7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> If user asks for a congestion control type with setsockopt() then it
> may be available as a module not included in the kernel already. 
> It should be autoloaded if needed.  This is done already when
> the default selection is change with sysctl, but not when application
> requests via sysctl.
> 
> Only reservation is are there any bad security implications from this?

There are already a quite large number of precedents for this, I think
this is one of the less questionable ones, the potential for (local)
damage is limited to minimal tcp_ca_find performance impact if I don't
miss anything (assuming no bugs in the modules that cause crashes
or something like that).

The in my opinion most questionable autoloading is in af_netlink BTW,
it will autoload any netlink provider with an appropriate module alias,
which could be just about anything (examples include conntrack, which
has performance and other side-effects, ULOG, which in turn loads
iptables, xfrm_user, connector, ...). Other autoloading is usually
limited to a clear scope of what might be affected.

