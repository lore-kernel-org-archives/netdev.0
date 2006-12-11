From: Brian Haley <brian.haley@hp.com>
Subject: Re: Fw: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS) returns
 -1
Date: Mon, 11 Dec 2006 16:55:55 -0500
Message-ID: <457DD3EB.9030201@hp.com>
References: <20061211095623.09fb0c40.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:35556 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761798AbWLKVz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 16:55:57 -0500
To: rdenis@simphalempin.com
In-Reply-To: <20061211095623.09fb0c40.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Where fd is a socket (datagram or raw) with IPv6 protocol family,
> getsockopt(fd, IPPROTO_IPV6, IPV6_UNICAST_HOPS, ...) succeeds, but the returned 
> hop limit is -1. connect()'ing the socket first does not solve the problem.

An IPv6 socket's hoplimit value is not set at creation time, instead, 
the hoplimit in an outgoing packet is set dynamically at transmit time 
to one of the following (in this order):

1. Hoplimit route metric (if set)
2. Outgoing interface value (/proc/sys/net/ipv6/conf/ethX/hop_limit)
3. Global IPv6 value (/proc/sys/net/ipv6/conf/all/hop_limit)

A setsockopt() value *will* override this.

Some *nixes have a different behavior and do set it at socket() creation 
time.

-Brian
