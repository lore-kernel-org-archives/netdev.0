From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Mon, 22 Oct 2012 15:11:23 -0700
Message-ID: <CAGK4HS9N9b64pKobWE=9wM-ZqNL-uJiGoAWNkqu=F=-NgHM=0Q@mail.gmail.com>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	<507C4401.7050500@oracle.com>
	<CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	<CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
	<5080279F.80008@oracle.com>
	<5080340F.3050207@oracle.com>
	<CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
	<CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
	<1350629413.2293.157.camel@edumazet-glaptop>
	<1350634013.2293.262.camel@edumazet-glaptop>
	<CAGK4HS_9mLzL9ESm=n5hvO0cw1hkHFMCSmBiYTBnqEMqQOvPvQ@mail.gmail.com>
	<1350642562.2293.411.camel@edumazet-glaptop>
	<alpine.DEB.2.00.1210221251520.1684@cleese>
	<1350936519.8609.1239.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: enh <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:54030 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756293Ab2JVWLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 18:11:24 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so2978077oag.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 15:11:23 -0700 (PDT)
In-Reply-To: <1350936519.8609.1239.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I wonder then if we dont need to retransmit the synack when req moves
> into accept_queue then ?


If I understood the code correctly, the socket moves into accept_queue
only when the
third ack (with or without data) comes in. So, there should be no need
to resend syn-ack. The issue is that there is no mechanism to promote
req sockets which have finished TWHS to accept_queue currently.
Socket can move into accept_queue only when third ack is processed.
If we stop resending synacks, then socket will move into accept_queue
when client sends data.

>
> Or else how the client can 'knows' it can send data to server ?

>From client's point of view, TWHS is finished.  Client is already in
established state and
can even now send data. Currently, such packets with data will be
dropped if accept_queue is full.
If accept_queue is not full, socket moves into accept_queue and
established state and processes the data.


I think the only thing my patch does is reorder the tests so that
needless syn-ack retransmissions are stopped.

>
> All these facilities sound very complex and not really usable by clients
> (ie users not willing to wait more than few seconds anyway)
>

Fair enough. We can drop this if it is not worth the trouble or if I
have missed any other scenario.

Thanks for your review and time!
Vijay
