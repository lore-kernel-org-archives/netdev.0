From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: [PATCH 0/3] Make mark-based routing work better with multiple
 separate networks.
Date: Tue, 13 May 2014 06:49:46 -0400
Message-ID: <CACP96tTRQqvQM6UTuqtVonZJW3LaHkBZkkpH+zCZa=GjHAEy+Q@mail.gmail.com>
References: <1399657021-26082-1-git-send-email-lorenzo@google.com>
	<CACP96tS0ikGfx85HX6t1w8+AENuiJu2N2-AyiJP+=VBohKjb4A@mail.gmail.com>
	<CAKD1Yr1ey0j03OtO3_tD+AREQwnk1J9Mx60-TcEP9QwEy4tdAw@mail.gmail.com>
	<CACP96tQO8PWyOKxR5gWWx4VvjjcTmkLhGHr_P2-WBCDEJpqL8Q@mail.gmail.com>
	<CAKD1Yr0z40vY8ucGDuLo8rPDudtHeOeMPbN_vfSSS_K4KjCffg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, JP Abgrall <jpa@google.com>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:64418 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbaEMKts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 06:49:48 -0400
Received: by mail-lb0-f179.google.com with SMTP id c11so122967lbj.10
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 03:49:46 -0700 (PDT)
In-Reply-To: <CAKD1Yr0z40vY8ucGDuLo8rPDudtHeOeMPbN_vfSSS_K4KjCffg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 6:53 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> On Tue, May 13, 2014 at 6:09 AM, sowmini varadhan <sowmini05@gmail.com> wrote:
>> http://lwn.net/Articles/407495/, a single
>> process should be able to open sockes in different namespaces.
>
> Other things that you can't do with namespaces are have the same physical
> interface (and the same IP address?) in two different namespaces, or
> have the same listening socket in two different namespaces. Namespaces
> are not a panacea.'

So this thread got unintentionally cut off by my not selecting Reply-All
in the google gui.

But to summarize a couple of private exchanges between Lorenzo and
me, it still appears to me that the use-case here is what routers
consider a "VRF". Thus it makes sense to add code (if/as needed)
to fix the VRF support in linux, rather than adding yet-another-one-off
feature with socket marking.

Specifically addressing the two issues raised above:
- yes, it is true that an interface can exist in only one netns at a time.
  But the same ip address can exist in multiple netns-es. If the
  app wants to listen to a proper-subset of networks that go in/out
  a single physical interface, you can use macvlan, and assign the
  macvlans to the desired netns.
- "same listening socket for multiple namespaces". Clearly that problem
  also exists for the socket-marks approach. But again this can actually
  be solved (for both netns and sock-marks) by having the application
  set up separate sockets for each netns (netns or whatever) of interest,
  and build an epoll fd over that set of sockets. No need for any kernel
  code for this.

  Or you can optimize this by building infra in the kernel to support the
  Wildcard ALL_VRFS notion. Or add even more code to support something
  less than ALL_VRFS.

My point is: what is the real networking construct that this use-case needs?
Isn't it what routers describe as the VRF? If yes, then shouldnt
we have one single way of supporting that in linux, instead of having
a little-bit-here and a little-bit-there?

--Sowmini
