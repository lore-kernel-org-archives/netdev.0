From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net v2] sctp: start t5 timer only when peer.rwnd is 0 and
 local.state is SHUTDOWN_PENDING
Date: Thu, 27 Aug 2015 22:49:06 +0800
Message-ID: <CADvbK_eZfJpQtvM_zTyS=3yTuCkdK0RM-zbMbFvUx5L-U9u5jQ@mail.gmail.com>
References: <e5d77a8d7c30ccbcc113506837ae7b8e90625046.1440329440.git.lucien.xin@gmail.com>
	<55DB5ED2.1050702@redhat.com>
	<20150824183146.GB1873@localhost.localdomain>
	<55DB644B.1090305@redhat.com>
	<CADvbK_cZhT3crJhP-5HQVpm=iAYTCDkiBNnDNCibvfOvEyzN7w@mail.gmail.com>
	<55DF10E6.3010007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	network dev <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@infradead.org>, davem <davem@davemloft.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36113 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbbH0OtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 10:49:06 -0400
Received: by oibi18 with SMTP id i18so7309205oib.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 07:49:06 -0700 (PDT)
In-Reply-To: <55DF10E6.3010007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> So one potential way is to have peer.rwnd and peer.a_rwnd, where peer.a_rwnd is
> the window advertised by peer and peer.rwnd and our estimation based on peer.a_rwnd.
> This way we will always know where we stand.
>
> Although I am not sure yet if we want to grow the peer structure any more.
>
> Another way is to have an estimate or 0-window probe bit/flags one the send side
> and set it when we do 0-window probe.  This way we'd know that when 0-window probe
> bit is set, peer returned 0 window.
>
I think updating 0-window may happen in sctp_process_init() and
sctp_outq_sack(),
I don't think 0-window can be probed, cause unreachable and closing
window both has
no reply from peer. but we can update the 0-window bit in those two
functions. I just do
not know where there is a available bit we can use if won't change the
peer structure.

> Just some thoughts.
> -vlad
