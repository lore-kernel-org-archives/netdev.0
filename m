From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Tue, 27 Oct 2009 16:24:34 -0700
Message-ID: <20091027162434.6dc31b2d@nehalam>
References: <4AE77F64.3090302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42399 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756486AbZJ0XYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 19:24:35 -0400
In-Reply-To: <4AE77F64.3090302@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Oct 2009 16:16:52 -0700
Ben Greear <greearb@candelatech.com> wrote:

> I have a very busy system with a bunch of xorp router processes (mis)configured.
> 
> This thing is rapidly making route changes for whatever reason.
> 
> The 'ip monitor route' command was failing:
> 
> [root@i7-dqc-1 ]# ip monitor route
> netlink receive error No buffer space available (105)
> Dump terminated
> 
> 
> It is only using a 32k rcv buffer, and it seems the OS was
> overdriving it.
> 
> Please consider making the rcv buffer larger, perhaps something
> like this (inline is white-space damaged...attachment should apply
> if deemed useful.):
> 
> Signed-off-by:  Ben Greear <greearb@candelatech.com>
> 
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index b68e2fd..95a7d1d 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -38,7 +38,7 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscriptions,
>   {
>          socklen_t addr_len;
>          int sndbuf = 32768;
> -       int rcvbuf = 32768;
> +       int rcvbuf = 3276800;
> 
>          memset(rth, 0, sizeof(*rth));
> 
> 
> Thanks,
> Ben
> 

Just having larger buffer isn't guarantee of success. Allocating
a huge buffer is not going to work on embedded.

Why not have it continue after one error.

-- 
