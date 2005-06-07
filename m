From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Mon, 6 Jun 2005 23:25:28 -0700
Message-ID: <OF9F62ECDB.67FFA191-ON88257019.001F5EA8-88257019.00234AB6@us.ibm.com>
References: <20050607.141922.65612976.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050607.141922.65612976.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

RFC 3542 broke the API-- they've defined options with
the same name, but different semantics.

Binaries using the old numbers would not work, unless
we return the old numbers in the control message types,
but in the new API, those have to be different from the
boolean option value (and equal to the sticky option value).

And those same binaries would not work when recompiled,
because the option names in the source would match the
new numbers, but still have the old arguments-- an error to
be detected at run-time, only.

My guess is that existing use of these is pretty limited, so
I'm not sure backward compatibility is worth it.

If we wanted to get really ugly, we could use the size of
the option value to determine what to do. Only two new
ancillary message types are int-sized (TCLASS and
HOPLIMIT). HOPLIMIT is not a valid socket option,
(done with IPV6_UNICAST_HOPS instead) and TCLASS
was not implemented at all-- not a problem. Then, in the
receive processing, we'd have to return the old message
type for programs using the sticky options as boolean,
and the new message type otherwise.

It's really ugly, but possible, I believe; then it would break
RFC 3542 compliance only in not treating boolean-sized
options as an error. But I think the better way is to fix programs
that use these right away. A program that uses "IPV6_RTHDR"
with a boolean argment is not portable (which is the whole
point of having a common API). We shouldn't encourage it
by making it continue to work.
                                        +-DLS
