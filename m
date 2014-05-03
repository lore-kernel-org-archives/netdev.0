From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: filter: add insn for loading internal
 transport header offset
Date: Fri, 02 May 2014 22:52:52 -0400 (EDT)
Message-ID: <20140502.225252.1865694187680020950.davem@davemloft.net>
References: <1398969880-8007-1-git-send-email-chema@google.com>
	<20140502.174928.1555908531689473830.davem@davemloft.net>
	<CA+ZOOTP88BJ-keuR5NznCgbDVPyzugWkdsVYjKkk5yGOBbkddQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, ast@plumgrid.com,
	netdev@vger.kernel.org
To: chema@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbaECCw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 22:52:56 -0400
In-Reply-To: <CA+ZOOTP88BJ-keuR5NznCgbDVPyzugWkdsVYjKkk5yGOBbkddQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chema Gonzalez <chema@google.com>
Date: Fri, 2 May 2014 17:53:01 -0700

> On Fri, May 2, 2014 at 2:49 PM, David Miller <davem@davemloft.net> wrote:
>> We can probably add an extension to AF_PACKET which provides the flow
>> key at the end of the tpacket3_hdr if a certain socket option is set.
>>
>> That would provide the transport header as well as a side effect, and
>> be much more powerful and efficient than this particular BPF
>> instruction.
> Once you get the L3 proto and noff/toff, you get everything. The
> rationale of adding toff/noff is that it's very similar to poff, which
> we already have.

But you're implementation is calling a function to do all of that work
already, just to get only the transport header and then throwing away
all of the other useful bits that function is calculating, so you'll
end up doing it twice which is wasted work.
