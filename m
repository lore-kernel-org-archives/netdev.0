From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] ieee802154: fix endianness and header
 handling
Date: Fri, 14 Mar 2014 22:16:22 -0400 (EDT)
Message-ID: <20140314.221622.701600181021063645.davem@davemloft.net>
References: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbaCOCQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 22:16:24 -0400
In-Reply-To: <1394828644-19898-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Fri, 14 Mar 2014 21:23:56 +0100

> This patch set enforces network byte order on all internal operations and
> fields of the 802.15.4 stack and adds a general representation of 802.15.4
> headers with operations to create and parse those headers. This reduces code
> duplication in the current stack and also allows for upper layers to read
> headers of packets they have just received; it is also necessary for 802.15.4
> link layer security, which requires header mangling.
 ...
> Changes since v1:
>  * fixed lowpan packet rx after reassembly. Control blocks were used to
>    retrieve source/dest addresses, but the CB is clobbered by reassembly.
>    Instead, parse the header anew in lowpan.

Series applied, thanks.

> What this patch set does *not* do is change endianness of the netlink/socket
> API. I would very much wish to change that as well. My research has uncovered
> two projects that use the stack, both of which extensively copy kernel headers
> that were never part of uapi and were also never installed as userspace headers
> before the uapi split. One of those projects is lowpan-tools[1], which is
> easily changed, and IBR-DTN[2], which does not seem to make much use of the
> stack either. In fact, the near uselessness of 6lowpan until a few weeks ago
> and a number of minor problems with datagram sockets suggests that nobody has
> ever used the stack for more than cursory experiments. Moreover, most projects
> on the internet that run on Linux and make some use of 802.15.4 radios even
> include their own drivers and often implement their own version of the protocol
> stack.
> 
> The fact that the only users I could find copy private headers to get their
> definitions would have me assume that it's okay to change those headers and the
> definitions, since the were never actually exposed. Is this correct, does it
> allow us to change the netlink/socket API that already exists?
> 
> [1] http://sourceforge.net/apps/trac/linux-zigbee/wiki
> [2] http://trac.ibr.cs.tu-bs.de/project-cm-2012-ibrdtn/

If the kernel exported an interface to the user, you're stuck with it, sorry.

It doesn't matter if the headers were messed up or incomplete.
