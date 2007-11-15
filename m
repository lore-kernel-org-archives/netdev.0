From: jamal <hadi@cyberus.ca>
Subject: Re: network interface state
Date: Thu, 15 Nov 2007 08:58:13 -0500
Message-ID: <1195135093.7203.19.camel@localhost>
References: <E1IsUCd-0005f4-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, drepper@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:5339 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060AbXKON6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:58:33 -0500
Received: by rv-out-0910.google.com with SMTP id k20so502218rvb
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2007 05:58:32 -0800 (PST)
In-Reply-To: <E1IsUCd-0005f4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-15-11 at 10:11 +0800, Herbert Xu wrote:

> We don't make use of that on recvmsg() though although theoretically
> user-space is supposed to be ready to handle that too.

iproute2 handles that well. Anyone writting netlink apps should program
with the thought that a single received datagram will include many
netlink messages.

On the concept of putting some generation marker/counter: 
It is one of those things that have bothered me as well for sometime,
but i cant think of a clean way to solve it for every user of netlink.
One way to transport this from the kernel is stash it in the netlink
sequence but that would violate things when a user expects a specific 
sequence. 

For the ifla/iflink, it should be trivial to solve by adding a marker in
the kernel that gets set to jiffies (or some incremental counter) every
time an event happens. You then transport this to user space as an
attribute anytime someone does a GET. 
Clearly the best way to solve it is to be generic, but we would need to
revamp netlink totaly.

Note, we do today signal to user space that a "message was lost" because
of buffer overrun. So a hack (not applicable to the poster given they
dont have a daemon) would be to listen to events and set the rx socket
buffer to be very small so you loose every message. 

cheers,
jamal

