From: Phil Sutter <phil@nwl.cc>
Subject: Re: iproute2 ss outputs duplicate tcp sockets info on kernel 3.10.105
Date: Wed, 10 May 2017 12:37:23 +0200
Message-ID: <20170510103723.GR20805@orbyte.nwl.cc>
References: <591121b4.213b9f0a.5aed.b3a8@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>
To: Li Er <phoooyb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56277 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752066AbdEJKhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 10 May 2017 06:37:25 -0400
Content-Disposition: inline
In-Reply-To: <591121b4.213b9f0a.5aed.b3a8@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Cc'ing Cyrill who wrote the code in question. Maybe he has an idea
what's going wrong here.

Cheers, Phil

On Mon, May 08, 2017 at 06:56:04PM -0700, Li Er wrote:
> i'm using v4.11.0 release of iproute2 and kernel 3.10.105, simply
> running
> 
>         $ ss
>         Netid  State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port
>         tcp    CLOSE-WAIT 434    0      10.0.0.1:47931                65.49.18.136:https
>         tcp    CLOSE-WAIT 432    0      10.0.0.1:47932                65.49.18.136:https
>         tcp    CLOSE-WAIT 434    0      10.0.0.1:47931                65.49.18.136:https
>         tcp    CLOSE-WAIT 432    0      10.0.0.1:47932                65.49.18.136:https
> 
> as you can see, there's one duplicate entry of each  tcp  socket,
> however,  if  i  explicitly  specify  tcp socket by adding the -t
> switch,
> 
>         $ ss -t
>         State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port
>         CLOSE-WAIT 434    0      10.0.0.1:47931                65.49.18.136:https
>         CLOSE-WAIT 432    0      10.0.0.1:47932                65.49.18.136:https
> 
> the duplication is gone.
> 
> this problem also occurs on  git  master,  but  not  on  iproute2
> v4.3.0,  so  i  did  a  git bisect and found out the commit which
> caused this is 9f66764e308e9c645b3fb2d1cfbb7fb207eb5de1,  and  by
> revert this commit on git master, i.e. removing
> 
>                                         err = rtnl_dump_done(rth, h);
>                                         if (err < 0)
>                                                 return -1;
> 
> these 3 lines of code of lib/libnetlink.c, the problem is gone.
> 
> since  i'm not familiar with the source code, i doubt this is the
> right way to solve the problem, what's your suggestions? thanks.
