From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: move to timewait when receiving data
 post active-close
Date: Wed, 18 Nov 2015 07:46:31 -0800
Message-ID: <1447861591.22599.157.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447859024-1040-1-git-send-email-fw@strlen.de>
	 <1447860480.22599.151.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151118153621.GA5860@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcelo.leitner@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36452 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207AbbKRPqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 10:46:34 -0500
Received: by pacdm15 with SMTP id dm15so48427751pac.3
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 07:46:34 -0800 (PST)
In-Reply-To: <20151118153621.GA5860@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 16:36 +0100, Florian Westphal wrote:

> Yes, but we kill the socket.
> 
> I should have added
> 
> 0.400 `ss -nito state time-wait`
> 
> as last line...
> 
> Before patch: no output
> after patch: tw socket shown.
> 
> The on-wire behavior doesn't change unless further packets arrive.
> Old behaviour: more RST
> New behaviour: acks+tw timer restart

Just add few more incoming packets to the packetdrill test then ?

Also, is your customer really _not_ using TCP timestamps ?

This is kind of a requirement for port reuse anyway.

Anyway, having a TIMEWAIT setup after sending a RST makes little sense
to me.

When a RST packet is sent, the remote peer will forget everything about
this previous connection, and another connect() might reuse the tuple
and I do not think we should forbid this. Normal PAWS checks were
invented for a good reason.

RFC 1122, 4.2.2.13 can be interpreted in very different ways.

Please show us real issue your customer has.
