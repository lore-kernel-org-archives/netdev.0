From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: santize headers for iproute2
Date: Mon, 24 Dec 2007 22:05:27 -0800 (PST)
Message-ID: <20071224.220527.254578945.davem@davemloft.net>
References: <20071221094336.63600b8c@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45320
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751108AbXLYGF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 01:05:28 -0500
In-Reply-To: <20071221094336.63600b8c@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Fri, 21 Dec 2007 09:43:36 -0800

> iproute2 source uses headers that result from "make headers_install".
> The header files net/tcp_states.h and net/veth.h are both being used
> but are not processed. 
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

The convention is to place user visible interfaces in header
files under include/linux/ and purely kernel internal bits
in header files under include/net/

Therefore exporting net/*.h headers is not right.

net/veth.h only defines user visible interfaces, so it
belongs under include/linux and added to include/linux/Kbuild,
and I would happily take a patch implementing that.

net/tcp_states.h is not movable to include/linux/ and thus to
userspace, it defines things that are present already in existing
userland header files.  If you look, <netinet/tcp.h> defines these
state values, as an enumeration.  If you need the TCPF_* flag bit
versions, sorry... you'll need to find some other way to get those
into userspace.
