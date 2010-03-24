From: Brandon Black <blblack@gmail.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Wed, 24 Mar 2010 14:55:28 -0500
Message-ID: <84621a61003241255i74282f53v3bb0111808895401@mail.gmail.com>
References: <84621a61003240915p2a4ce6bbjd0c6bfb02ab05ba8@mail.gmail.com>
	 <4BAA4EE4.3090900@nortel.com>
	 <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>
	 <4BAA69BF.3080600@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BAA69BF.3080600@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 24, 2010 at 2:36 PM, Chris Friesen <cfriesen@nortel.com> wr=
ote:
> Note that I said "large numbers of sockets". =C2=A0Like tens of thous=
ands.
> In addition to context switch overhead this can also lead to issues w=
ith
> memory consumption due to stack frames.

Ok, agreed there.  In my case though, there will only ever be a
handful of sockets.  Ideally it would be just one socket.  The only
reason I allocate multiple sockets and spawn threads for them is
because you can't scale past one CPU core on a single socket, due to
the NIC and/or the driver and/or the socket locks and/or the basic
nature of the problem.

> Consider the case where you want to do some other useful work in
> addition to running your network server. =C2=A0Every cpu cycle spent =
on the
> network server is robbed from the other work. =C2=A0In this scenario =
you want
> to handle packets as efficiently as possible, so the timeout-based
> behaviour is better since it is more likely to give you multiple pack=
ets
> per syscall.

That's a good point, I tend to tunnelvision on the dedicated server
scenario.  I should probably have a user-level option for
timeout-based operation as well, since the decision here gets to the
systems admin/engineering level and will be situational.

Thanks,
-- Brandon
