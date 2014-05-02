From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: filter: add insn for loading internal
 transport header offset
Date: Fri, 02 May 2014 17:49:28 -0400 (EDT)
Message-ID: <20140502.174928.1555908531689473830.davem@davemloft.net>
References: <1398882591-30422-1-git-send-email-chema@google.com>
	<1398969880-8007-1-git-send-email-chema@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, ast@plumgrid.com,
	netdev@vger.kernel.org
To: chema@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbaEBVta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 17:49:30 -0400
In-Reply-To: <1398969880-8007-1-git-send-email-chema@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chema Gonzalez <chema@google.com>
Date: Thu,  1 May 2014 11:44:40 -0700

> Patch adds an ANC_TRA_OFFSET insn that loads the internal transport
> header of a packet ("internal" meaning after decapsulation by the
> flow dissector).
> 
> Signed-off-by: Chema Gonzalez <chema@google.com>

I'm not so convinced of this change.

What are the use cases?

If the use cases are to simply pull the ports out of the transport
header for filter matching or hashing, don't just make a half-step
like this.

We can probably add an extension to AF_PACKET which provides the flow
key at the end of the tpacket3_hdr if a certain socket option is set.

That would provide the transport header as well as a side effect, and
be much more powerful and efficient than this particular BPF
instruction.
