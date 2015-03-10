From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/8] net/socket: sock_map_fd - reverse allocation order
Date: Tue, 10 Mar 2015 05:26:48 -0700
Message-ID: <1425990408.8261.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
	 <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
	 <1425936003-24544-3-git-send-email-zenczykowski@gmail.com>
	 <20150309.235605.1023100303494694986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, maze@google.com, edumazet@google.com,
	tytso@mit.edu, netdev@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35371 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbCJM0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 08:26:51 -0400
Received: by iecsf10 with SMTP id sf10so11668525iec.2
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 05:26:49 -0700 (PDT)
In-Reply-To: <20150309.235605.1023100303494694986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 23:56 -0400, David Miller wrote:
> From: Maciej =C5=BBenczykowski <zenczykowski@gmail.com>
> Date: Mon,  9 Mar 2015 14:19:58 -0700
>=20
> > From: Maciej =C5=BBenczykowski <maze@google.com>
> >=20
> > Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> The ordering of these operations was carefully choosen over the years
> such that we prioritize "easy" things to allocate and recover from,
> before harder things.
>=20
> And allocating and releasing an 'fd' is much cheaper to deal with tha=
n
> a socket file object.
>=20
> And as has been shown in the accept() case, you're even changing user
> visible semantics.
>=20
> If you really want to reduce the amount of locking, create __*()
> interfaces that assume the files lock is held already, and take
> them around a batch of related operations.
>=20
> By adding the file argument to the fs interfaces you making the calle=
r
> become a contortionist in order to fit into the interfaces
> requirements.  Just let the callers do what they already do, which we
> already know is correct and properly prioritized ordering wise, and
> control the locking at a higher level.

In accept() case, the socket operation can block, so we cannot hold the
lock.

Ideally, as discussed with Al Viro in last Kernel Summit, we would need
to convert the file descriptor management to use RCU, and atomic
bit ops. That would be a very tricky change.
