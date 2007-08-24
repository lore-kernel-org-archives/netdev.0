From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Problem with implementation of TCP_DEFER_ACCEPT?
Date: Fri, 24 Aug 2007 09:15:30 +0200
Message-ID: <20070824071530.GB26447@xi.wantstofly.org>
References: <1187914105.26866.41.camel@bagoas.tjworld.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: TJ <linux@tjworld.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:59786 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbXHXHPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 03:15:33 -0400
Content-Disposition: inline
In-Reply-To: <1187914105.26866.41.camel@bagoas.tjworld.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 01:08:25AM +0100, TJ wrote:

> An RFC 793 standard TCP handshake requires three packets:
> 
> client SYN > server LISTENING
> client < SYN ACK server SYN_RECEIVED
> client ACK > server ESTABLISHED
> 
> client PSH ACK + data > server
> 
> TCP_DEFER_ACCEPT is designed to increase performance by reducing the
> number of TCP packets exchanged before the client can pass data:
> 
> client SYN > server LISTENING
> client < SYN ACK server SYN_RECEIVED
> 
> client PSH ACK + data > server ESTABLISHED
> 
> At present with TCP_DEFER_ACCEPT the kernel treats the RFC 793 handshake
> as invalid; dropping the ACK from the client without replying so the
> client doesn't know the server has in fact set it's internal ACKed flag.
> 
> If the client doesn't send a packet containing data before the SYN_ACK
> time-outs finally expire the connection will be dropped.

A brought this up a long, long time ago, and I seem to remember
Alexey Kuznetsov explained me at the time that this was intentional.

I can't find the thread in the mailing list archives anymore, though
-- and my memory might be failing me.
