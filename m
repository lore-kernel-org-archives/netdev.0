From: kuznet@ms2.inr.ac.ru
Subject: Re: raw ipv6 broken in 2.4.19
Date: Tue, 13 Aug 2002 17:58:58 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208131358.RAA21125@sex.inr.ac.ru>
References: <1029246435.1135.22.camel@tux>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: gandalf@wlug.westbo.se (Martin Josefsson)
In-Reply-To: <1029246435.1135.22.camel@tux> from "Martin Josefsson" at Aug 13, 2 03:47:15 pm
List-Id: netdev.vger.kernel.org

Hello!

> If the packets recieved is really corrupted wouldn't something have
> complained before that patch was merged in 2.4.19-pre8 ?

No. We simply forgot to verify checksum on raw packets. :-)


> if the ipv6 header was corrupt it would have been dropped?

No, ipv6 has no checksum on header. Corruptions there will remain
unnoticed.


> if the icmp packet was corrupt, wouldn't ping6 have complained?

Provided wrong bits are in data area, it would dump wrong bits
comparing them to original. But if it is in timestamp or in header,
it also would remain unnoticed before 2.4.19.

Very strange. We have similar phenomenon reported with TCP, by the way.
So, I have to assume that checksumming routine is wrong and does some shit
sort of relying on an uninitialized data.

Alexey
