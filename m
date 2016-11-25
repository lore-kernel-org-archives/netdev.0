From: Eli Cooper <elicooper@gmx.com>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Fri, 25 Nov 2016 10:18:12 +0800
Message-ID: <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
References: <20161125120947.142c3af5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:56020 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750984AbcKYCSX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 21:18:23 -0500
In-Reply-To: <20161125120947.142c3af5@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On 2016/11/25 9:09, Stephen Rothwell wrote:
> Hi all,
>
> This is a typical user error report i.e. a net well specified one :-)
>
> I am using a 6in4 tunnel from my Linux server at home (since my ISP
> does not provide native IPv6) to another hosted Linus server (that has
> native IPv6 connectivity).  The throughput for IPv6 connections has
> dropped from megabits per second to 10s of kilobits per second.
>
> First, I am using Debian supplied kernels, so strike one, right?
>
> Second, I don't actually remember when the problem started - it probably
> started when I upgraded from a v4.4 based kernel to a v4.7 based one.
> This server does not get rebooted very often as it runs hosted services
> for quite a few people (its is ozlabs.org ...).
>
> I tried creating the same tunnel to another hosted server I have access
> to that is running a v3.16 based kernel and the performance is fine
> (actually upward of 40MB/s).
>
> I noticed from a tcpdump on the hosted server that (when I fetch a
> large file over HTTP) the server is sending packets larger than the MTU
> of the tunnel.  These packets don't get acked and are later resent as
> MTU sized packets.  I will then send more larger packets and repeat ...

Sounds like TSO/GSO packets are not properly segmented and therefore
dropped.

Could you first try turning off segmentation offloading for the tunnel
interface?
    ethtool -K sit0 tso off gso off

> The mtu of the tunnel is set to 1280 (though leaving it unset and using
> the default gave the same results).  The tunnel is using sit and is
> statically set up at both ends (though the hosted server end does not
> specify a remote ipv4 end point).
>
> Is there anything else I can tell you?  Testing patches is a bit of a
> pain, unfortunately, but I was hoping that someone may remember
> something that may have caused this.

Regards,
Eli
