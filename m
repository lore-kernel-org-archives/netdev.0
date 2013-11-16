From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] socket: don't return uninitialized addresses on
 concurrent socket shutdown
Date: Fri, 15 Nov 2013 22:32:49 -0800
Message-ID: <1384583569.8604.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com>
	 <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com>
	 <20131116054344.GG26901@order.stressinduktion.org>
	 <20131116054814.GH26901@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:35344 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab3KPGcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 01:32:53 -0500
Received: by mail-pb0-f54.google.com with SMTP id ro12so4552908pbb.27
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 22:32:52 -0800 (PST)
In-Reply-To: <20131116054814.GH26901@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-16 at 06:48 +0100, Hannes Frederic Sowa wrote:
> If a blocking read waits on a socket which gets concurrently shut down we
> return 0 as error and so indicate success to the socket functions which
> thus copy an uninitialized stack allocated address back to the user.
> Fix this by clearing the 128 byte size (on x86-64) address first.
> 
> This patch fixes the problem for recvfrom, recvmsg and recvmmsg.
> 
> Reported-by: mpb <mpb.mail@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Are you clearing 128 bytes on every recvfrom() system call, just in case
of this shutdown() issue ?

Can't we avoid this overhead ?

msg.msg_namelen should be set to 0 in this case.
