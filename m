From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 84991] New: Adding a gre tunnel causes a kernel panic
Date: Mon, 22 Sep 2014 10:09:27 -0700
Message-ID: <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140922090242.5ef15c83@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:55728 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbaIVRJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 13:09:31 -0400
Received: by mail-pd0-f182.google.com with SMTP id p10so4601132pdj.13
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 10:09:31 -0700 (PDT)
In-Reply-To: <20140922090242.5ef15c83@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-22 at 09:02 -0700, Stephen Hemminger wrote:
> Not good, and user did bisection.
> 
> using git bisect, the below commit introduced the above bug.
> 
> [7d442fab0a6777fd7612cfcada32ea859553d370] ipv4: Cache dst in tunnels
> 
> 
> commit 7d442fab0a6777fd7612cfcada32ea859553d370
> Author: Tom Herbert <therbert@google.com>
> Date:   Thu Jan 2 11:48:26 2014 -0800
> 
>     ipv4: Cache dst in tunnels
> 
>     Avoid doing a route lookup on every packet being tunneled.
> 
>     In ip_tunnel.c cache the route returned from ip_route_output if
>     the tunnel is "connected" so that all the rouitng parameters are
>     taken from tunnel parms for a packet. Specifically, not NBMA tunnel
>     and tos is from tunnel parms (not inner packet).
> 
>     Signed-off-by: Tom Herbert <therbert@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
> Begin forwarded message:
> 
> Date: Sun, 21 Sep 2014 16:56:08 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 84991] New: Adding a gre tunnel causes a kernel panic
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=84991
> 
>             Bug ID: 84991
>            Summary: Adding a gre tunnel causes a kernel panic
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.17.0-rc5 #82 SMP PREEMPT
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: joe9mail@gmail.com
>         Regression: No

Thanks, I'll send a fix.
