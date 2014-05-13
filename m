From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Tue, 13 May 2014 08:28:23 -0700
Message-ID: <CAKD1Yr2YtX9eGeFOeMb=s3_yqhhJgWEb+G0JH26UPRDPfZ5MgQ@mail.gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>
 <CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
 <CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com>
 <CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com>
 <CAKD1Yr0z40vY8ucGDuLo8rPDudtHeOeMPbN_vfSSS_K4KjCffg@mail.gmail.com> <CACP96tTRQqvQM6UTuqtVonZJW3LaHkBZkkpH+zCZa=GjHAEy+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:52741 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaEMP2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 11:28:44 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so5315249igb.5
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 08:28:44 -0700 (PDT)
In-Reply-To: <CACP96tTRQqvQM6UTuqtVonZJW3LaHkBZkkpH+zCZa=GjHAEy+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 3:49 AM, sowmini varadhan <sowmini05@gmail.com> wrote:
> Specifically addressing the two issues raised above:
> - yes, it is true that an interface can exist in only one netns at a time.
>   But the same ip address can exist in multiple netns-es. If the
>   app wants to listen to a proper-subset of networks that go in/out
>   a single physical interface, you can use macvlan, and assign the
>   macvlans to the desired netns.

You can't use macvlan if you're not using interfaces that don't have
MAC addresses such as tun devices, 4G interfaces, and so on.

> - "same listening socket for multiple namespaces". Clearly that problem
>   also exists for the socket-marks approach. But again this can actually
>   be solved (for both netns and sock-marks) by having the application
>   set up separate sockets for each netns (netns or whatever) of interest,
>   and build an epoll fd over that set of sockets. No need for any kernel
>   code for this.

IMO forcing an application to open one socket per namespace, and
constantly be listening for any namespace changes as networks come and
go, is an unreasonable burden when all the application wants to do is
"accept connections on port 80 from everywhere". It's true that it
requires no kernel code, but you could also observe that no kernel
code is required for TCP, since it can all be done by the app using
raw sockets.

> My point is: what is the real networking construct that this use-case needs?
> Isn't it what routers describe as the VRF? If yes, then shouldnt
> we have one single way of supporting that in linux, instead of having
> a little-bit-here and a little-bit-there?

This is not a little-bit-here and a little-bit there. Socket marking
is an existing feature and this patch makes it work better when
different fwmarks identify different networks, without needing
namespace isolation, moving sockets between namespaces, etc.
