From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: TCP hangs
Date: Tue, 4 May 2004 23:20:05 +0200 (CEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.58.0405042314220.2573@artax.karlin.mff.cuni.cz>
References: <Pine.LNX.4.58.0405021602120.20423@artax.karlin.mff.cuni.cz>
 <409583B1.5040906@us.ibm.com> <Pine.LNX.4.58.0405031238110.18691@artax.karlin.mff.cuni.cz>
 <4097B8D1.4010008@us.ibm.com> <Pine.LNX.4.58.0405041811300.11971@artax.karlin.mff.cuni.cz>
 <4097C966.5080509@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264642AbUEDVVS@vger.kernel.org>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <4097C966.5080509@us.ibm.com>
List-Id: netdev.vger.kernel.org



On Tue, 4 May 2004, Nivedita Singhvi wrote:

> Mikulas Patocka wrote:
>
> >TCP should send RST on received data after shutdown(SHUT_RD) ---
> >RFC2525, sections 2.16, 2.17.
> >
> >
>
> Yes, but that should lead to a shutdown on both ends. If you
> have sent a reset, why are you not tearing down your end of
> whatever remains of the connection? You have asked the
> other side to tear down. RFC 793:
>
> "The receiver of a RST first validates it, then changes
> state.  If the receiver was in the LISTEN state, it ignores it.
> If the receiver was in SYN-RECEIVED state and had previously
> been in the LISTEN state, then the receiver returns to the
> LISTEN state, otherwise the receiver aborts the connection
> and goes to the CLOSED state.  If the receiver was in any
> other state, it aborts the connection and advises the user
> and goes to the CLOSED state."

Good point. Now I see that in client's code, that it doesn't kill the
connection after sending reset. However if it did, the trace would look
exactly the same, because when client receives packet for port without
connection, it would reply with RST anyway.

Mikulas
