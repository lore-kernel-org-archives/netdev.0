From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next 02/12] tipc: Add "max_ports" configuration
 parameter
Date: Fri, 31 May 2013 11:23:02 +0200
Message-ID: <20130531092302.GA8131@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130531082538.GB17727@eerihug-hybrid.ki.sw.ericsson.se>
 <20130531.012922.204204156468438634.davem@davemloft.net>
 <20130531083455.GA7568@eerihug-hybrid.ki.sw.ericsson.se>
 <20130531.014028.420559536226155172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:45796 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439Ab3EaJXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 05:23:05 -0400
Content-Disposition: inline
In-Reply-To: <20130531.014028.420559536226155172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 01:40:28AM -0700, David Miller wrote:
> We never shrink the hash tables once we've grown them.  That's a
> reasonable way to behave.

Very well.
Currently, the refs/portID's are built up of a random part, and an index
part. The index is obtained by masking against the table size.
If the table is allowed to grow, we must remove the random part from the 
portID. Otherwise we would index out a nonexistant or wrong port
from a received packet..

But removing the random part would be a violation of the protocol spec, and
potentially break interop between other implementations (like link selection..)

//E
