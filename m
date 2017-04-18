From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: Add early demux handler for UDP
 unicast
Date: Tue, 18 Apr 2017 11:16:33 -0400 (EDT)
Message-ID: <20170418.111633.1943544161712972224.davem@davemloft.net>
References: <8b6968063320eb8ddc654f79d3461f21@codeaurora.org>
        <1489000921.28631.18.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170418080902.GA25804@vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, subashab@codeaurora.org,
        netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753040AbdDRPQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:16:35 -0400
In-Reply-To: <20170418080902.GA25804@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Tue, 18 Apr 2017 17:09:04 +0900

> On Wed, Mar 08, 2017 at 11:22:01AM -0800, Eric Dumazet wrote:
>> On Wed, 2017-03-08 at 12:11 -0700, Subash Abhinov Kasiviswanathan wrote:
>> > On 2017-03-08 11:40, Eric Dumazet wrote:
>> > > Well, this 'optimization' actually hurts when UDP sockets are not
>> > > connected, since this adds an extra cache line miss per incoming 
>> > > packet.
>> > > 
>> > > (DNS servers for example)
>> > 
>> > Hi Eric
>> > 
>> > Thanks for your comments. Would it be preferable to disable early demux 
>> > for the
>> > servers with large unconnected workloads in that case?
>> 
>> Well, many servers handle both TCP and UDP.
>> 
>> For TCP, there is no question about early demux, this is definitely a
>> win.
>> 
>> We probably should have one sysctl to enable TCP early demux, one for
>> UDP early demux.
> 
> If early demux is a clear win for TCP then I wonder if it is
> unnecessary and by some leap also undesirable to have a configuration
> knob for that case.

For forwarding workloads it is pure overhead since the early demux will
never find a local socket, and therefore it is wasted work.
