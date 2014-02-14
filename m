From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Does ICMP_FRAG_NEEDED automatically update the routing cache?
Date: Fri, 14 Feb 2014 15:44:12 +0100
Message-ID: <20140214144412.GA27343@order.stressinduktion.org>
References: <26474.1392388608@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54990 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbaBNOoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 09:44:13 -0500
Content-Disposition: inline
In-Reply-To: <26474.1392388608@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Feb 14, 2014 at 02:36:48PM +0000, David Howells wrote:
> Am I reading the ipv4 code right?  If a UDP packet we send results in an
> ICMP_FRAG_NEEDED packet being received, the cached routing information for the
> peer will automatically be updated by __udp4_lib_err()?

A next hop exception will be generated (or reused) which stores the path
mtu towards that target, yes (there is no more routing cache).

Prior to that a validation check happens if the socket really exists (this is
e.g. needed to identify the namespace or routing table the update should occur
on).

> And something similar in __udp6_lib_err()?

Exactly.

Greetings,

  Hannes
