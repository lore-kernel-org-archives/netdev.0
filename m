From: "David S. Miller" <davem@redhat.com>
Subject: Re: Possible weird TCP bug
Date: Tue, 13 Jan 2004 16:01:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113160135.45cc677d.davem@redhat.com>
References: <3FFE2B00.2030607@chartermi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nathaniel M Nelson <nmn@chartermi.net>
In-Reply-To: <3FFE2B00.2030607@chartermi.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 08 Jan 2004 23:16:00 -0500
Nathaniel M Nelson <nmn@chartermi.net> wrote:

> 0000  00 02 7d 66 a4 54 00 e0  81 23 14 78 08 00 45 00   ..}f.T.. .#.x..E.
> 0010  00 3c 9a 41 40 00 3f 06  f4 1f 18 e7 92 21 d8 ef   .<.A@.?. .....!..
> 0020  29 63 89 37 00 50 e5 4b  22 e0 00 00 00 00 a0 02   )c.7.P.K ".......
> 0030  16 d0 36 6a 00 00 02 04  05 b4 04 02 08 0a 03 1d   ..6j.... ........
> 0040  b8 a1 00 00 00 00 01 03  03 00                     ........ ..     
> 
> Then after I get the SYN,ACK back, the firewall will send out the next 
> ACK with the sequence number correctly incremented by 1.
> 
> 0000  00 02 7d 66 a4 54 00 e0  81 23 14 78 08 00 45 00   ..}f.T.. .#.x..E.
> 0010  00 28 9a 42 40 00 3f 06  f4 32 18 e7 92 21 d8 ef   .(.B@.?. .2...!..
> 0020  29 63 89 37 00 50 e5 4b  22 e1 db f2 5c c5 50 10   )c.7.P.K "...\.P.
> 0030  16 d0 21 3d 00 00                                  ..!=.
> 
> So of course the sequence is "1" in that packet.  Both sequence numbers 
> seem a little low though... and not very cryptic.  If this is not a bug 
> I apoligize in advance.

In the initial packet, the only zero is the "ACK" sequence, when the first SYN
goes out we don't know the starting sequence number the other side will
decide to use so we set that field to zero (and also the ACK bit is clear in this
packet which makes the ACK sequence field not valid anyways).

This dump looks perfectly fine to me.
