From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: ipv6: Add early demux handler for UDP unicast
Date: Tue, 18 Apr 2017 20:09:08 +0200
Message-ID: <1492538948.1052073.948360488.79052FB2@webmail.messagingengine.com>
References: <8b6968063320eb8ddc654f79d3461f21@codeaurora.org>
 <1489000921.28631.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170418080902.GA25804@vergenet.net>
 <20170418.111633.1943544161712972224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, subashab@codeaurora.org,
        netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33915 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751378AbdDRSJJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 14:09:09 -0400
In-Reply-To: <20170418.111633.1943544161712972224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Apr 18, 2017, at 17:16, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Tue, 18 Apr 2017 17:09:04 +0900
> 
> > On Wed, Mar 08, 2017 at 11:22:01AM -0800, Eric Dumazet wrote:
> >> On Wed, 2017-03-08 at 12:11 -0700, Subash Abhinov Kasiviswanathan wrote:
> >> > On 2017-03-08 11:40, Eric Dumazet wrote:
> >> > > Well, this 'optimization' actually hurts when UDP sockets are not
> >> > > connected, since this adds an extra cache line miss per incoming 
> >> > > packet.
> >> > > 
> >> > > (DNS servers for example)
> >> > 
> >> > Hi Eric
> >> > 
> >> > Thanks for your comments. Would it be preferable to disable early demux 
> >> > for the
> >> > servers with large unconnected workloads in that case?
> >> 
> >> Well, many servers handle both TCP and UDP.
> >> 
> >> For TCP, there is no question about early demux, this is definitely a
> >> win.
> >> 
> >> We probably should have one sysctl to enable TCP early demux, one for
> >> UDP early demux.
> > 
> > If early demux is a clear win for TCP then I wonder if it is
> > unnecessary and by some leap also undesirable to have a configuration
> > knob for that case.
> 
> For forwarding workloads it is pure overhead since the early demux will
> never find a local socket, and therefore it is wasted work.

Also for some more complicated fib rules setups the early demux logic
could end up causing doing wrong lookups, because some route might not
be actually local in one fib rule but it is in another one.

Bye,
Hannes
