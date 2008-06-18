From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: Killing sk->sk_callback_lock (was Re: [PATCH]
	net/core/sock.c remove extra wakeup)
Date: Wed, 18 Jun 2008 10:49:28 -0600
Message-ID: <4858E838020000C7000397CF@lucius.provo.novell.com>
References: <4857F579020000B30004963C@lucius.provo.novell.com>
 <4858E838020000C7000397CF@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, "Gregory Haskins" <GHaskins@novell.com>,
	<chuck.lever@oracle.com>, <netdev@vger.kernel.org>
To: <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucius.provo.novell.com ([137.65.248.127]:53850 "EHLO
	lucius.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945AbYFRQtc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:49:32 -0400
In-Reply-To: <4858E838020000C7000397CF@lucius.provo.novell.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-18 at 09:33 +1000, Herbert Xu wrote:

> This is buggy.  You're relying on the caller to not call this
> on the same socket concurrently.  While this may be true for
> UDP right now (which is a less than ideal situation in itself),
> it isn't true in general.  In particular, raw sockets still
> allow parallel writes to the same socket.
> 
Point taken, I wasn't aware of the raw sockets usage. In that case,
there would be a race introduced that can't be solved with bit flags.
As a side note, it also seems the setting of the NOSPACE flag is
useless here as well.
> So forget about the flags and just do the two queues as you proposed
> yourself :)
> 
I will give it a shot - I still have reservations about changing the
socket structures - at first glance, it seems like sock and socket will
have to change.
> Cheers,

Thanks.
Pat


