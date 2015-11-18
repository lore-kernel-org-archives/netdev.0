From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 11:19:48 +0100
Message-ID: <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
 <20151117192738.365145d7@samsung9>
 <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51061 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752182AbbKRKTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 05:19:49 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 705432093E
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 05:19:48 -0500 (EST)
In-Reply-To: <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Nov 18, 2015, at 05:04, Eric Dumazet wrote:
> On Tue, 2015-11-17 at 19:27 -0800, Stephen Hemminger wrote:
> 
> > I understand why you might want this, but it smells like the same
> > kind of problems that the "forced unmount" patch had which eventually
> > led to it not being accepted in mainline.  Lots of corner
> > cases and race conditions waiting to blow up.
> 
> Well, disconnecting a TCP socket seems straightforward, once you get a
> sk pointer.
> 
> Code looks good.
> 
> > 
> > Look at the issues that the multi-thread socket close has.
> > This looks worse.
> 
> I do not see a problem here. A RST packet has roughly same effect, and
> we do process them.
> 
> Cookies are 64bits and uniquely identify a socket.
> 
> Once you make sure the request comes from a privileged user, we are
> good.
> 
> This user could easily install some iptables rules to generate RST
> packets anyway.

I bet there will soon be a timewaitd which handles the not configurable
(David has rejected all those patches so far) timeout of TIME_WAIT
sockets. And I bet it will be used. :/

Bye,
Hannes
