From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH V4 net 0/2] ipv6: fix flowlabel issue for reset packet
Date: Wed, 9 Aug 2017 09:40:08 -0700
Message-ID: <CALx6S36DcpqqqhosdN4qNqTNYZkxZ=0Qy-=uKXHVM_yQoE4XbQ@mail.gmail.com>
References: <cover.1501539150.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, Shaohua Li <shli@fb.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36447 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752349AbdHIQkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:40:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id d40so121284wma.3
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 09:40:09 -0700 (PDT)
In-Reply-To: <cover.1501539150.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 3:19 PM, Shaohua Li <shli@kernel.org> wrote:
> From: Shaohua Li <shli@fb.com>
>
> Please see below tcpdump output:
> 21:00:48.109122 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payl=
oad length: 40) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.555=
5: Flags [S], cksum 0x0529 (incorrect -> 0xf56c), seq 3282214508, win 43690=
, options [mss 65476,sackOK,TS val 2500903437 ecr 0,nop,wscale 7], length 0
> 21:00:48.109381 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payl=
oad length: 40) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.5580=
4: Flags [S.], cksum 0x0529 (incorrect -> 0x49ad), seq 1923801573, ack 3282=
214509, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 25009034=
37,nop,wscale 7], length 0
> 21:00:48.109548 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payl=
oad length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.555=
5: Flags [.], cksum 0x0521 (incorrect -> 0x1bdf), seq 1, ack 1, win 342, op=
tions [nop,nop,TS val 2500903437 ecr 2500903437], length 0
> 21:00:48.109823 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payl=
oad length: 62) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.555=
5: Flags [P.], cksum 0x053f (incorrect -> 0xb8b1), seq 1:31, ack 1, win 342=
, options [nop,nop,TS val 2500903437 ecr 2500903437], length 30
> 21:00:48.109910 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payl=
oad length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.5580=
4: Flags [.], cksum 0x0521 (incorrect -> 0x1bc1), seq 1, ack 31, win 342, o=
ptions [nop,nop,TS val 2500903437 ecr 2500903437], length 0
> 21:00:48.110043 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payl=
oad length: 56) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.5580=
4: Flags [P.], cksum 0x0539 (incorrect -> 0xb726), seq 1:25, ack 31, win 34=
2, options [nop,nop,TS val 2500903438 ecr 2500903437], length 24
> 21:00:48.110173 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payl=
oad length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.555=
5: Flags [.], cksum 0x0521 (incorrect -> 0x1ba7), seq 31, ack 25, win 342, =
options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
> 21:00:48.110211 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP (6) payl=
oad length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.5580=
4: Flags [F.], cksum 0x0521 (incorrect -> 0x1ba7), seq 25, ack 31, win 342,=
 options [nop,nop,TS val 2500903438 ecr 2500903437], length 0
> 21:00:48.151099 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payl=
oad length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.555=
5: Flags [.], cksum 0x0521 (incorrect -> 0x1ba6), seq 31, ack 26, win 342, =
options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
> 21:00:49.110524 IP6 (flowlabel 0x43304, hlim 64, next-header TCP (6) payl=
oad length: 56) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12:3456.555=
5: Flags [P.], cksum 0x0539 (incorrect -> 0xb324), seq 31:55, ack 26, win 3=
42, options [nop,nop,TS val 2500904438 ecr 2500903438], length 24
> 21:00:49.110637 IP6 (flowlabel 0xb34d5, hlim 64, next-header TCP (6) payl=
oad length: 20) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:3456.5580=
4: Flags [R], cksum 0x0515 (incorrect -> 0x668c), seq 1923801599, win 0, le=
ngth 0
>
> The flowlabel of reset packet (0xb34d5) and flowlabel of normal packet
> (0xd827f) are different. This causes our router doesn't correctly close t=
cp
> connection. The patches try to fix the issue.
>
Shaohua,

Can you give some more detail about what the router doesn't close the
TCP connection means? I'm guessing the problem is either: 1) the
router is maintaining connection state that includes the flow label in
a connection tuple. 2) some router in the path is maintaining
connection state, but when the flow label changes the flow's packet
are routed through a different router that doesn't have a state for
the flow it drops the packet. #1 should be easily fix in the router,
flow labels cannot be used as state. #2 is the known problem that
stateful firewalls have killed our ability to use multihoming.

Another consideration is that sk_txhash is also used in routing
decisions by the local host (flow label is normally derived from
txhash). If you want to ensure that connections are routed
consistently for timewait state you might need sk_txhash saved also.

Tom

> Thanks,
> Shaohua
>
> Shaohua Li (2):
>   net: remove unnecessary rotation
>   net: fix tcp reset packet flowlabel for ipv6
>
>  include/net/ipv6.h       | 15 ++++-----------
>  net/ipv4/tcp_minisocks.c |  8 +++++++-
>  net/ipv6/ip6_gre.c       |  2 +-
>  net/ipv6/ip6_output.c    |  4 ++--
>  net/ipv6/ip6_tunnel.c    |  2 +-
>  net/ipv6/tcp_ipv6.c      | 18 +++++++++++++++++-
>  6 files changed, 32 insertions(+), 17 deletions(-)
>
> --
> 2.9.3
>
