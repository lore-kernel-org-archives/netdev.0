From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Large performance regression with 6in4 tunnel (sit)
Date: Fri, 25 Nov 2016 12:09:47 +1100
Message-ID: <20161125120947.142c3af5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:42931 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750708AbcKYBJu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 20:09:50 -0500
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ozlabs.org (Postfix) with ESMTPSA id 3tPyfN1QGJz9t1H
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 12:09:48 +1100 (AEDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is a typical user error report i.e. a net well specified one :-)

I am using a 6in4 tunnel from my Linux server at home (since my ISP
does not provide native IPv6) to another hosted Linus server (that has
native IPv6 connectivity).  The throughput for IPv6 connections has
dropped from megabits per second to 10s of kilobits per second.

First, I am using Debian supplied kernels, so strike one, right?

Second, I don't actually remember when the problem started - it probably
started when I upgraded from a v4.4 based kernel to a v4.7 based one.
This server does not get rebooted very often as it runs hosted services
for quite a few people (its is ozlabs.org ...).

I tried creating the same tunnel to another hosted server I have access
to that is running a v3.16 based kernel and the performance is fine
(actually upward of 40MB/s).

I noticed from a tcpdump on the hosted server that (when I fetch a
large file over HTTP) the server is sending packets larger than the MTU
of the tunnel.  These packets don't get acked and are later resent as
MTU sized packets.  I will then send more larger packets and repeat ...

The mtu of the tunnel is set to 1280 (though leaving it unset and using
the default gave the same results).  The tunnel is using sit and is
statically set up at both ends (though the hosted server end does not
specify a remote ipv4 end point).

Is there anything else I can tell you?  Testing patches is a bit of a
pain, unfortunately, but I was hoping that someone may remember
something that may have caused this.
-- 
Cheers,
Stephen Rothwell
