From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip: set the close-on-exec flag for descriptors
Date: Mon, 08 Jul 2013 07:17:16 -0700
Message-ID: <1373293036.4979.105.camel@edumazet-glaptop>
References: <1370332874-584-1-git-send-email-avagin@openvz.org>
	 <20130604091150.48f3b1ca@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Vagin <avagin@openvz.org>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:65361 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464Ab3GHORS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 10:17:18 -0400
Received: by mail-pa0-f42.google.com with SMTP id rl6so4445646pac.15
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 07:17:17 -0700 (PDT)
In-Reply-To: <20130604091150.48f3b1ca@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-04 at 09:11 -0700, Stephen Hemminger wrote:
> On Tue,  4 Jun 2013 12:01:14 +0400
> Andrey Vagin <avagin@openvz.org> wrote:
> 
> > Otherwise a program executed by "ip netns exec" has two extra
> > descriptors.
> > 
> > $ ip netns exec test /bin/bash
> > $ lsof -p $$
> > ...
> > bash    817 root    0u   CHR  136,0       0t0          3 /dev/pts/0
> > bash    817 root    1u   CHR  136,0       0t0          3 /dev/pts/0
> > bash    817 root    2u   CHR  136,0       0t0          3 /dev/pts/0
> > bash    817 root    3u  sock    0,6       0t0      13386 protocol: NETLINK
> > bash    817 root    4r   REG    0,3         0 4026532155 net
> > bash    817 root  255u   CHR  136,0       0t0          3 /dev/pts/0
> 
> Applied

It seems it could break ip command for old kernels, as SOCK_CLOEXEC is
supported from 2.6.27

Not sure if its worth a patch, to do the normal socket() call followed
by legacy fcntl() one.
