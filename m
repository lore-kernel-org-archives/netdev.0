From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: use gfp insteaad of GFP_NOWAIT in
 idr_alloc_cyclic when sctp_assoc_set_id
Date: Sun, 6 Mar 2016 13:52:30 +0800
Message-ID: <CADvbK_faS8mNtUNiVT6d-kLRnngQ=4+z6meuO0XM+RJG50iaNw@mail.gmail.com>
References: <ef48b2b8895b4d0fab07b4e72b464d5a11d3bd79.1457193572.git.lucien.xin@gmail.com>
	<1457196133.2663.3.camel@edumazet-ThinkPad-T530>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:34797 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbcCFFwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 00:52:31 -0500
In-Reply-To: <1457196133.2663.3.camel@edumazet-ThinkPad-T530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 6, 2016 at 12:42 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On sam., 2016-03-05 at 23:59 +0800, Xin Long wrote:
>
> Are you sure idr_alloc(... GFP_KERNEL) makes sense inside spin_lock_bh()
> section ?
>
> idr_alloc() has :
>
> might_sleep_if(gfpflags_allow_blocking(gfp_mask));
>
> A debug kernel (CONFIG_DEBUG_ATOMIC_SLEEP=y) should probably complain at
> this point ?
>
OK, I got you, does it make sense to you if I just change GFP_NOWAIT
to GFP_ATOMIC
when sctp_assoc_set_id call idr_alloc_cyclic()?  which also can avoid
this call trace in my
test.

>
>
