From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Sat, 13 Nov 2010 13:42:34 -0500
Message-ID: <1289673754.3090.362.camel@Dan>
References: <1289673008.3090.350.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:50528 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab0KMSnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 13:43:41 -0500
In-Reply-To: <1289673008.3090.350.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually, this is not even a joke.
> 
> Take a look at how we track what sockets a user wants dumped via
> the inet_diag netlink facility, the socket pointer is used as
> the identification cookie.
> 
> I'm sure we'll now get some more security theatre about how we
> have to undo that too.
> 
> More and more I see this whole idea as extremely rediculious.
> 
> If I can write to or read kernel memory, I can look up the
> sockets, inodes, and whatever else we're currently exposing
> the addresses of.  Even without a symbol table, which is
> readily available, I can easily find the ksymtab and find the
> inode and socket hash table addresses there.
> 
> This whole exercise is closing the barn door after the horses have
> already escaped, and it's causing all kinds of inconveniences
> that we really have no need for.

Of course if you can both write and read to kernel memory, this is a
pointless exercise, but those are not the conditions I am trying to
defend against.  Proactive security assumes that individual bugs will
continue to be found, and takes steps to prevent exploitation of classes
of bugs on a broader scale.  In this case, the goal is for it to be
difficult to exploit arbitrary write bugs WITHOUT having a separate
arbitrary read bug.  Several other steps are being taken in this
direction - there is open discussion about the merits of hiding symbol
information, address space randomization, marking various likely targets
as read-only, and restricting access to debugging information.  However,
none of this really accomplishes much if addresses are still exposed
via /proc.

I'm sorry that you see all this as "security theatre".  It's clear that
there's too much resistance to this effort for it to ever succeed, so
I'm ceasing attempts to get this patch series through.

-Dan

