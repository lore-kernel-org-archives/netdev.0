From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] net/socket: sock_map_fd - reverse allocation order
Date: Mon, 09 Mar 2015 23:56:05 -0400 (EDT)
Message-ID: <20150309.235605.1023100303494694986.davem@davemloft.net>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
	<1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
	<1425936003-24544-3-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, edumazet@google.com, tytso@mit.edu,
	netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbCJD4I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 23:56:08 -0400
In-Reply-To: <1425936003-24544-3-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon,  9 Mar 2015 14:19:58 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

The ordering of these operations was carefully choosen over the years
such that we prioritize "easy" things to allocate and recover from,
before harder things.

And allocating and releasing an 'fd' is much cheaper to deal with than
a socket file object.

And as has been shown in the accept() case, you're even changing user
visible semantics.

If you really want to reduce the amount of locking, create __*()
interfaces that assume the files lock is held already, and take
them around a batch of related operations.

By adding the file argument to the fs interfaces you making the caller
become a contortionist in order to fit into the interfaces
requirements.  Just let the callers do what they already do, which we
already know is correct and properly prioritized ordering wise, and
control the locking at a higher level.
