From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/3]sysctl: make the sys.net.core sysctls
 per-namespace
Date: Sat, 08 Dec 2007 00:10:38 -0800 (PST)
Message-ID: <20071208.001038.256039822.davem@davemloft.net>
References: <47594587.6060308@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45055
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757043AbXLHIKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 03:10:39 -0500
In-Reply-To: <47594587.6060308@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 16:07:19 +0300

> Making them per-namespace is required for the following 
> two reasons:
> 
>  First, some ctl values have a per-namespace meaning.
>  Second, making them writable from the sub-namespace
>  is an isolation hole.
> 
> So I introduce the pernet operations to create these
> tables. For init_net I use the existing statically
> declared tables, for sub-namespace they are duplicated
> and the write bits are removed from the mode.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25, but I fear you're going to need to do something
similar for ipv4, ipv6, and who knows what other protocols.  And as a
result we'll end up with all kinds of protocol specific things in the
net namespace structure which totally stinks.

Such things will need to be registered dynamically just like the
protocols themselves are into the kernel.
