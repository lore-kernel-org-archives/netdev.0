From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: set the close-on-exec flag for descriptors
Date: Mon, 8 Jul 2013 12:50:07 -0700
Message-ID: <20130708125007.6ee941ba@nehalam.linuxnetplumber.net>
References: <1370332874-584-1-git-send-email-avagin@openvz.org>
	<20130604091150.48f3b1ca@nehalam.linuxnetplumber.net>
	<1373293036.4979.105.camel@edumazet-glaptop>
	<CANaxB-wjwobCnYBsL2mpR9V=WR5w7_cCgR6Pp9OA72rtVsD27A@mail.gmail.com>
	<1373299506.4979.112.camel@edumazet-glaptop>
	<CANaxB-zLiUsr2OG2J65jb8sa6G4i93m2j=-3F5_p+WB-Xd8ZhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Andrey Wagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:52125 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab3GHTuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 15:50:12 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa11so4711373pad.5
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 12:50:11 -0700 (PDT)
In-Reply-To: <CANaxB-zLiUsr2OG2J65jb8sa6G4i93m2j=-3F5_p+WB-Xd8ZhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Jul 2013 23:23:35 +0400
Andrey Wagin <avagin@gmail.com> wrote:

> 2013/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Mon, 2013-07-08 at 19:51 +0400, Andrey Wagin wrote:
> >> Hi Eric,
> >>
> >> 2013/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
> >> >> Applied
> >> >
> >> > It seems it could break ip command for old kernels, as SOCK_CLOEXEC is
> >> > supported from 2.6.27
> >> >
> >> > Not sure if its worth a patch, to do the normal socket() call followed
> >> > by legacy fcntl() one.
> >>
> >> fcntl is not safe for multithread applications. If libnetlink isn't
> >> going to be used for them, I don't have objection. The patch is
> >> attached.
> >>
> >
> > If you want multithread safety, you could attempt the SOCK_CLOEXEC, and
> > fall back in case of error to legacy socket()/fcntl()
> >
> 
> Yes, it's good idea. Look at the attached patch.
> 
> Thanks.
> 
> >
> >

Just always do the fcntl(), it makes more sense rather than having
two code paths.
