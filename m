From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 18:08:22 +0100
Message-ID: <1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
 <20151119.005318.838757439536205791.davem@davemloft.net>
 <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
 <20151119.104811.1447518072450380661.davem@davemloft.net>
 <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, lorenzo@google.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, dtor@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:44219 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756659AbbKSRIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 12:08:23 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 4C18D2088B
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 12:08:22 -0500 (EST)
In-Reply-To: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015, at 17:19, Eric Dumazet wrote:
> On Thu, 2015-11-19 at 10:48 -0500, David Miller wrote:
> > At least if they do it this way, and someone claims that Linux TCP
> > behaves outside the spec or improperly, it's not directly because of
> > any code I am responsible for.
> > 
> > That's the difference, and frankly an important one to me.
> > 
> > If I'm going to give userspace a direct tool by which to do things,
> > then it's suddenly my responsibility and my problem.
> 
> Here is the thing :
> 
> - Android powered phones and devices have a similar code since 2008.
> There is _no_ way they can avoid having this functionality.
> 
> Every-time I make a change in linux TCP stack, this code breaks, and
> this a  real pain because Android changes need to be carried over to
> vendors.
> 
> I worked closely with Lorenzo, removing the ugly code Android had, and
> proposed an implementation based on inet_diag.
> 
> We have a clear business case here, and I would like we find a solution.
> 
> Having this code in upstream kernel will save me time and energy to deal
> with real issues and improvements, not with bugs opened by Android
> engineers 9 months after I did changes in upstream kernels.
> 
> Having comments like "look, just implement application keepalives" is
> not going to work [1][2]. This is terrible, and show lack of
> understanding of the problem. We are not dealing with DC communications
> here. (I wish !)
> 
> We (TCP stack) compete with QUIC, based on UDP, which has no issues like
> that. We need to allow TCP sessions being signaled of a non temporary
> network disruption.
> 
> [1] Phones are very often in very polluted radio environments.
> 
>   I remember the terrible wifi we had during Linux Kernel Summit in
> Chicago, where ping had more than 40 seconds delay.
> 
> Here the network manager can avoid this 40 seconds penalty.
> 
> [2] Taking air time to send keepalive(s) and receive their answers is
> going to make all radio providers shout really loud. They are already
> installing stupid proxies filtering/compressing ACK messages and
> breaking TCP clocking.
> 
> Please add
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Please wait one month for people submitting a working alternative,
> I am fine with it as long it is upstream.

I actually don't have an issue with killing from user space that much. I
still recommend (and actually have started to look at it today) to add a
new substate for TCP TIMEWAIT and don't have any issue if we block the
socket for 60 seconds and send RSTs to all incoming data. This way we
can solve the problem Florian indicated as well as this problem. Users
can happily kill TCP connections then.

Bye,
Hannes
