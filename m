From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH V4 net 0/2] ipv6: fix flowlabel issue for reset packet
Date: Tue, 15 Aug 2017 07:08:31 -0700
Message-ID: <CALx6S34f2r-sQi_gNAS9mxTX0JPeOJrhN8q3wzD-14knCB7DUA@mail.gmail.com>
References: <cover.1501539150.git.shli@fb.com> <CALx6S36DcpqqqhosdN4qNqTNYZkxZ=0Qy-=uKXHVM_yQoE4XbQ@mail.gmail.com>
 <20170810163033.kriwd2pivmuuzfnb@kernel.org> <CALx6S35UKD3AyqxM-zKMCANi=TR_e26mRjKYKH7QreckBu2dEg@mail.gmail.com>
 <20170810191314.vo6yl7dgndga4heh@kernel.org> <CALx6S34CwcYNtBzEoEMrBP3O54Fsnot=YzeHCNCM0yeuaFUozQ@mail.gmail.com>
 <20170815025224.trjgcp3z6i3cgfy2@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, Shaohua Li <shli@fb.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33675 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdHOOIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:08:32 -0400
Received: by mail-qk0-f175.google.com with SMTP id a77so4696834qkb.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 07:08:32 -0700 (PDT)
In-Reply-To: <20170815025224.trjgcp3z6i3cgfy2@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 7:52 PM, Shaohua Li <shli@kernel.org> wrote:
> On Fri, Aug 11, 2017 at 06:00:20PM -0700, Tom Herbert wrote:
>> On Thu, Aug 10, 2017 at 12:13 PM, Shaohua Li <shli@kernel.org> wrote:
>> > On Thu, Aug 10, 2017 at 11:30:51AM -0700, Tom Herbert wrote:
>> >> On Thu, Aug 10, 2017 at 9:30 AM, Shaohua Li <shli@kernel.org> wrote:
>> >> > On Wed, Aug 09, 2017 at 09:40:08AM -0700, Tom Herbert wrote:
>> >> >> On Mon, Jul 31, 2017 at 3:19 PM, Shaohua Li <shli@kernel.org> wrot=
e:
>> >> >> > From: Shaohua Li <shli@fb.com>
>> >> >> >
>> >> >> > Please see below tcpdump output:
>> >> >> > 21:00:48.109122 IP6 (flowlabel 0x43304, hlim 64, next-header TCP=
 (6) payload length: 40) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12=
:3456.5555: Flags [S], cksum 0x0529 (incorrect -> 0xf56c), seq 3282214508, =
win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 0,nop,wscale 7],=
 length 0
>> >> >> > 21:00:48.109381 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP=
 (6) payload length: 40) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:=
3456.55804: Flags [S.], cksum 0x0529 (incorrect -> 0x49ad), seq 1923801573,=
 ack 3282214509, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr=
 2500903437,nop,wscale 7], length 0
>> >> >> > 21:00:48.109548 IP6 (flowlabel 0x43304, hlim 64, next-header TCP=
 (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12=
:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1bdf), seq 1, ack 1, wi=
n 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
>> >> >> > 21:00:48.109823 IP6 (flowlabel 0x43304, hlim 64, next-header TCP=
 (6) payload length: 62) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12=
:3456.5555: Flags [P.], cksum 0x053f (incorrect -> 0xb8b1), seq 1:31, ack 1=
, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 30
>> >> >> > 21:00:48.109910 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP=
 (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:=
3456.55804: Flags [.], cksum 0x0521 (incorrect -> 0x1bc1), seq 1, ack 31, w=
in 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
>> >> >> > 21:00:48.110043 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP=
 (6) payload length: 56) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:=
3456.55804: Flags [P.], cksum 0x0539 (incorrect -> 0xb726), seq 1:25, ack 3=
1, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 24
>> >> >> > 21:00:48.110173 IP6 (flowlabel 0x43304, hlim 64, next-header TCP=
 (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12=
:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba7), seq 31, ack 25, =
win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
>> >> >> > 21:00:48.110211 IP6 (flowlabel 0xd827f, hlim 64, next-header TCP=
 (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:=
3456.55804: Flags [F.], cksum 0x0521 (incorrect -> 0x1ba7), seq 25, ack 31,=
 win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length 0
>> >> >> > 21:00:48.151099 IP6 (flowlabel 0x43304, hlim 64, next-header TCP=
 (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12=
:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba6), seq 31, ack 26, =
win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
>> >> >> > 21:00:49.110524 IP6 (flowlabel 0x43304, hlim 64, next-header TCP=
 (6) payload length: 56) fec0::5054:ff:fe12:3456.55804 > fec0::5054:ff:fe12=
:3456.5555: Flags [P.], cksum 0x0539 (incorrect -> 0xb324), seq 31:55, ack =
26, win 342, options [nop,nop,TS val 2500904438 ecr 2500903438], length 24
>> >> >> > 21:00:49.110637 IP6 (flowlabel 0xb34d5, hlim 64, next-header TCP=
 (6) payload length: 20) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff:fe12:=
3456.55804: Flags [R], cksum 0x0515 (incorrect -> 0x668c), seq 1923801599, =
win 0, length 0
>> >> >> >
>> >> >> > The flowlabel of reset packet (0xb34d5) and flowlabel of normal =
packet
>> >> >> > (0xd827f) are different. This causes our router doesn't correctl=
y close tcp
>> >> >> > connection. The patches try to fix the issue.
>> >> >> >
>> >> >> Shaohua,
>> >> >>
>> >> >> Can you give some more detail about what the router doesn't close =
the
>> >> >> TCP connection means? I'm guessing the problem is either: 1) the
>> >> >> router is maintaining connection state that includes the flow labe=
l in
>> >> >> a connection tuple. 2) some router in the path is maintaining
>> >> >> connection state, but when the flow label changes the flow's packe=
t
>> >> >> are routed through a different router that doesn't have a state fo=
r
>> >> >> the flow it drops the packet. #1 should be easily fix in the route=
r,
>> >> >> flow labels cannot be used as state. #2 is the known problem that
>> >> >> stateful firewalls have killed our ability to use multihoming.
>> >> >
>> >> > The #2 is exactly the problem we saw.
>> >> >
>> >> >> Another consideration is that sk_txhash is also used in routing
>> >> >> decisions by the local host (flow label is normally derived from
>> >> >> txhash). If you want to ensure that connections are routed
>> >> >> consistently for timewait state you might need sk_txhash saved als=
o.
>> >> >
>> >> > As far as I understood, we don't use sk_txhash for routing selectio=
n. The code
>> >> > does routing selection with flowlabel user configured, at that time=
 we don't
>> >> > derive fl6.flowlabel from skb->hash (which is from sk_txhash). The =
code always
>> >> > does routing selection first and then uses ip6_make_flowlabel to bu=
ild packet
>> >> > data where we derive flowlabel from skb->hash.
>> >> >
>> >> That is assuming one particular use case. Generally, if you want to
>> >> ensure all packets for a flow take the same path you'll need tx_hash
>> >> and make it persistent (disable flow bender). For instance, if you
>> >> were doing UDP encapsulation like in VXLAN the UDP source port
>> >> selection is unaffected by saved flow label for the lifetime of the
>> >> flow. So we would still hit #2 in that case and the stateful device
>> >> doesn't see whole flow. It might be just as easy to move tx_hash in
>> >> skc_common so that it's available in TW state for this purpose. Then
>> >> when moving to TW state just copy the tx_hash.
>> >
>> > Hi Tom,
>> >
>> > My original implementation is to add a tx_hash in tw sock, we then cop=
y sock's
>> > tx_hash to the tw tx_hash. This does makes things simplier. One concer=
n from
>> > Eric is this will increase the size of tw sock. If we move tx_hash to
>> > skc_common, all sock size will increase, is this acceptable?
>>
>> I think that can only be measured by how critical it is to
>> persistently route all packets the same exact way for every
>> connection. Page one of the IP book clearly states that IP packets can
>> be dropped, duplicated, or received out of order. Received OOO implies
>> that packet for the same flow are allowed to take different paths. The
>> requirement that packets for the same flow must always take the same
>> path through the network was created by stateful middleboxes-- it's
>> not inherent in the architecture of IP networking. Unfortunately,
>> we're seeing this become more and more of a problem as more devices
>> are multi-homed (like smart phones) and these network requirement
>> cripple our ability to take advantage of features like that.
>>
>> Personally, I wish the middleboxes fix the problem they created, but I
>> suppose we need to be pragmatic at least in the short term.
>
> Hmm, I still hesitate to add a new field in skc_common. Fixing current pr=
oblem
> looks propriate in current stage. I'd defer fixing the generic issue till=
 it's
> necessary.
>
Shaohua,

An alternative would be to not initialize sk_txhash, but instead defer
hash computation to use flow dissector in the TX path when the hash is
needed (to get flow label, src port for UDP encap, route for
multipath, etc.). At the first hash computation in TX path  the result
in sk_txhash. In TW state there is no socket so flow dissector is
always used but that should yield the same hash. No extra fields would
be needed and additional cost is negligible.

Tom

> Thanks,
> Shaohua
