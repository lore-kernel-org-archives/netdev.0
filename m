From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH V4 net 0/2] ipv6: fix flowlabel issue for reset packet
Date: Thu, 17 Aug 2017 12:07:47 -0700
Message-ID: <CALx6S37h-uFZrruQ8KWVp+BRKDEVKe-bPbJAS2oMFsXFr8PTpg@mail.gmail.com>
References: <cover.1501539150.git.shli@fb.com> <CALx6S36DcpqqqhosdN4qNqTNYZkxZ=0Qy-=uKXHVM_yQoE4XbQ@mail.gmail.com>
 <20170810163033.kriwd2pivmuuzfnb@kernel.org> <CALx6S35UKD3AyqxM-zKMCANi=TR_e26mRjKYKH7QreckBu2dEg@mail.gmail.com>
 <20170810191314.vo6yl7dgndga4heh@kernel.org> <CALx6S34CwcYNtBzEoEMrBP3O54Fsnot=YzeHCNCM0yeuaFUozQ@mail.gmail.com>
 <20170815025224.trjgcp3z6i3cgfy2@kernel.org> <CALx6S34f2r-sQi_gNAS9mxTX0JPeOJrhN8q3wzD-14knCB7DUA@mail.gmail.com>
 <20170815224252.6vjkyqsngybl3z3m@kernel.org> <CALx6S34C5aT+UX-Rz39iu5FX-U-EAw23ZiBEcGP90HZRj4xf+g@mail.gmail.com>
 <20170817172602.mmv73kjxuwwimxo6@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Martin KaFai Lau <kafai@fb.com>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35300 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753272AbdHQTHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 15:07:49 -0400
Received: by mail-qk0-f173.google.com with SMTP id 130so7193325qkg.2
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 12:07:49 -0700 (PDT)
In-Reply-To: <20170817172602.mmv73kjxuwwimxo6@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 10:26 AM, Shaohua Li <shli@kernel.org> wrote:
> On Tue, Aug 15, 2017 at 05:15:46PM -0700, Tom Herbert wrote:
>> On Tue, Aug 15, 2017 at 3:42 PM, Shaohua Li <shli@kernel.org> wrote:
>> > On Tue, Aug 15, 2017 at 07:08:31AM -0700, Tom Herbert wrote:
>> >> On Mon, Aug 14, 2017 at 7:52 PM, Shaohua Li <shli@kernel.org> wrote:
>> >> > On Fri, Aug 11, 2017 at 06:00:20PM -0700, Tom Herbert wrote:
>> >> >> On Thu, Aug 10, 2017 at 12:13 PM, Shaohua Li <shli@kernel.org> wro=
te:
>> >> >> > On Thu, Aug 10, 2017 at 11:30:51AM -0700, Tom Herbert wrote:
>> >> >> >> On Thu, Aug 10, 2017 at 9:30 AM, Shaohua Li <shli@kernel.org> w=
rote:
>> >> >> >> > On Wed, Aug 09, 2017 at 09:40:08AM -0700, Tom Herbert wrote:
>> >> >> >> >> On Mon, Jul 31, 2017 at 3:19 PM, Shaohua Li <shli@kernel.org=
> wrote:
>> >> >> >> >> > From: Shaohua Li <shli@fb.com>
>> >> >> >> >> >
>> >> >> >> >> > Please see below tcpdump output:
>> >> >> >> >> > 21:00:48.109122 IP6 (flowlabel 0x43304, hlim 64, next-head=
er TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.55804 > fec0::5054:f=
f:fe12:3456.5555: Flags [S], cksum 0x0529 (incorrect -> 0xf56c), seq 328221=
4508, win 43690, options [mss 65476,sackOK,TS val 2500903437 ecr 0,nop,wsca=
le 7], length 0
>> >> >> >> >> > 21:00:48.109381 IP6 (flowlabel 0xd827f, hlim 64, next-head=
er TCP (6) payload length: 40) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff=
:fe12:3456.55804: Flags [S.], cksum 0x0529 (incorrect -> 0x49ad), seq 19238=
01573, ack 3282214509, win 43690, options [mss 65476,sackOK,TS val 25009034=
37 ecr 2500903437,nop,wscale 7], length 0
>> >> >> >> >> > 21:00:48.109548 IP6 (flowlabel 0x43304, hlim 64, next-head=
er TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:f=
f:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1bdf), seq 1, ack=
 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
>> >> >> >> >> > 21:00:48.109823 IP6 (flowlabel 0x43304, hlim 64, next-head=
er TCP (6) payload length: 62) fec0::5054:ff:fe12:3456.55804 > fec0::5054:f=
f:fe12:3456.5555: Flags [P.], cksum 0x053f (incorrect -> 0xb8b1), seq 1:31,=
 ack 1, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length=
 30
>> >> >> >> >> > 21:00:48.109910 IP6 (flowlabel 0xd827f, hlim 64, next-head=
er TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff=
:fe12:3456.55804: Flags [.], cksum 0x0521 (incorrect -> 0x1bc1), seq 1, ack=
 31, win 342, options [nop,nop,TS val 2500903437 ecr 2500903437], length 0
>> >> >> >> >> > 21:00:48.110043 IP6 (flowlabel 0xd827f, hlim 64, next-head=
er TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff=
:fe12:3456.55804: Flags [P.], cksum 0x0539 (incorrect -> 0xb726), seq 1:25,=
 ack 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], lengt=
h 24
>> >> >> >> >> > 21:00:48.110173 IP6 (flowlabel 0x43304, hlim 64, next-head=
er TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:f=
f:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba7), seq 31, ac=
k 25, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
>> >> >> >> >> > 21:00:48.110211 IP6 (flowlabel 0xd827f, hlim 64, next-head=
er TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff=
:fe12:3456.55804: Flags [F.], cksum 0x0521 (incorrect -> 0x1ba7), seq 25, a=
ck 31, win 342, options [nop,nop,TS val 2500903438 ecr 2500903437], length =
0
>> >> >> >> >> > 21:00:48.151099 IP6 (flowlabel 0x43304, hlim 64, next-head=
er TCP (6) payload length: 32) fec0::5054:ff:fe12:3456.55804 > fec0::5054:f=
f:fe12:3456.5555: Flags [.], cksum 0x0521 (incorrect -> 0x1ba6), seq 31, ac=
k 26, win 342, options [nop,nop,TS val 2500903438 ecr 2500903438], length 0
>> >> >> >> >> > 21:00:49.110524 IP6 (flowlabel 0x43304, hlim 64, next-head=
er TCP (6) payload length: 56) fec0::5054:ff:fe12:3456.55804 > fec0::5054:f=
f:fe12:3456.5555: Flags [P.], cksum 0x0539 (incorrect -> 0xb324), seq 31:55=
, ack 26, win 342, options [nop,nop,TS val 2500904438 ecr 2500903438], leng=
th 24
>> >> >> >> >> > 21:00:49.110637 IP6 (flowlabel 0xb34d5, hlim 64, next-head=
er TCP (6) payload length: 20) fec0::5054:ff:fe12:3456.5555 > fec0::5054:ff=
:fe12:3456.55804: Flags [R], cksum 0x0515 (incorrect -> 0x668c), seq 192380=
1599, win 0, length 0
>> >> >> >> >> >
>> >> >> >> >> > The flowlabel of reset packet (0xb34d5) and flowlabel of n=
ormal packet
>> >> >> >> >> > (0xd827f) are different. This causes our router doesn't co=
rrectly close tcp
>> >> >> >> >> > connection. The patches try to fix the issue.
>> >> >> >> >> >
>> >> >> >> >> Shaohua,
>> >> >> >> >>
>> >> >> >> >> Can you give some more detail about what the router doesn't =
close the
>> >> >> >> >> TCP connection means? I'm guessing the problem is either: 1)=
 the
>> >> >> >> >> router is maintaining connection state that includes the flo=
w label in
>> >> >> >> >> a connection tuple. 2) some router in the path is maintainin=
g
>> >> >> >> >> connection state, but when the flow label changes the flow's=
 packet
>> >> >> >> >> are routed through a different router that doesn't have a st=
ate for
>> >> >> >> >> the flow it drops the packet. #1 should be easily fix in the=
 router,
>> >> >> >> >> flow labels cannot be used as state. #2 is the known problem=
 that
>> >> >> >> >> stateful firewalls have killed our ability to use multihomin=
g.
>> >> >> >> >
>> >> >> >> > The #2 is exactly the problem we saw.
>> >> >> >> >
>> >> >> >> >> Another consideration is that sk_txhash is also used in rout=
ing
>> >> >> >> >> decisions by the local host (flow label is normally derived =
from
>> >> >> >> >> txhash). If you want to ensure that connections are routed
>> >> >> >> >> consistently for timewait state you might need sk_txhash sav=
ed also.
>> >> >> >> >
>> >> >> >> > As far as I understood, we don't use sk_txhash for routing se=
lection. The code
>> >> >> >> > does routing selection with flowlabel user configured, at tha=
t time we don't
>> >> >> >> > derive fl6.flowlabel from skb->hash (which is from sk_txhash)=
. The code always
>> >> >> >> > does routing selection first and then uses ip6_make_flowlabel=
 to build packet
>> >> >> >> > data where we derive flowlabel from skb->hash.
>> >> >> >> >
>> >> >> >> That is assuming one particular use case. Generally, if you wan=
t to
>> >> >> >> ensure all packets for a flow take the same path you'll need tx=
_hash
>> >> >> >> and make it persistent (disable flow bender). For instance, if =
you
>> >> >> >> were doing UDP encapsulation like in VXLAN the UDP source port
>> >> >> >> selection is unaffected by saved flow label for the lifetime of=
 the
>> >> >> >> flow. So we would still hit #2 in that case and the stateful de=
vice
>> >> >> >> doesn't see whole flow. It might be just as easy to move tx_has=
h in
>> >> >> >> skc_common so that it's available in TW state for this purpose.=
 Then
>> >> >> >> when moving to TW state just copy the tx_hash.
>> >> >> >
>> >> >> > Hi Tom,
>> >> >> >
>> >> >> > My original implementation is to add a tx_hash in tw sock, we th=
en copy sock's
>> >> >> > tx_hash to the tw tx_hash. This does makes things simplier. One =
concern from
>> >> >> > Eric is this will increase the size of tw sock. If we move tx_ha=
sh to
>> >> >> > skc_common, all sock size will increase, is this acceptable?
>> >> >>
>> >> >> I think that can only be measured by how critical it is to
>> >> >> persistently route all packets the same exact way for every
>> >> >> connection. Page one of the IP book clearly states that IP packets=
 can
>> >> >> be dropped, duplicated, or received out of order. Received OOO imp=
lies
>> >> >> that packet for the same flow are allowed to take different paths.=
 The
>> >> >> requirement that packets for the same flow must always take the sa=
me
>> >> >> path through the network was created by stateful middleboxes-- it'=
s
>> >> >> not inherent in the architecture of IP networking. Unfortunately,
>> >> >> we're seeing this become more and more of a problem as more device=
s
>> >> >> are multi-homed (like smart phones) and these network requirement
>> >> >> cripple our ability to take advantage of features like that.
>> >> >>
>> >> >> Personally, I wish the middleboxes fix the problem they created, b=
ut I
>> >> >> suppose we need to be pragmatic at least in the short term.
>> >> >
>> >> > Hmm, I still hesitate to add a new field in skc_common. Fixing curr=
ent problem
>> >> > looks propriate in current stage. I'd defer fixing the generic issu=
e till it's
>> >> > necessary.
>> >> >
>> >> Shaohua,
>> >>
>> >> An alternative would be to not initialize sk_txhash, but instead defe=
r
>> >> hash computation to use flow dissector in the TX path when the hash i=
s
>> >> needed (to get flow label, src port for UDP encap, route for
>> >> multipath, etc.). At the first hash computation in TX path  the resul=
t
>> >> in sk_txhash. TW state there is no socket so flow dissector is
>> >> always used but that should yield the same hash. No extra fields woul=
d
>> >> be needed and additional cost is negligible.
>> >
>> > Hi Tom,
>> >
>> > Did you mean revert 877d1f6291f8(net: Set sk_txhash from a random numb=
er)? This
>> > could fix the issue. So in normal case we calculate the sk_txhash usin=
g flow
>> > dissector but in negative routing case we use the random hash, is this=
 what you
>> > want?
>> >
>> No. What you'd want is something like a sysctl that sets an alternate
>> mode for sk_txhash processing. sk_txhash is derived from flow
>> dissector for the first TX packet and then it's never allowed to
>> change. Maybe this should be called persistent-hash mode.
>
> persistent-hash will almostly mean disabling auto flowlabel. We'd prefer
> disabling auto flowlabel rather than the persistent-hash. But I think we =
do
> want to use the auto flowlabel for load balancing, so the persistent-hash=
 isn't
> a go for us.
>
Those are two separate features here. Auto flow label means
automatically generating flow labels for packets based on some hash. A
persistent hash means that once a hash is determined for a connection
it never changes, so the flow label derived from the hash never
changes.

> Let's take the other way. Your main concern is the multipath selection. I=
 think
> this can be fixed. We can still use the tw->tw_flowlabel to store the aut=
o
> created flowlabel like what my patch does, but we use an extra bit in tw_=
pad of
> inet_timewait_sock to indicate this flowlabel is auto created. In the res=
et
> packet send path, we don't use the auto created flowlabel for route slect=
ion,
> but just for packet data. This will keep current multipath selection beha=
vior
> and fix the reset packet flowlabel issue.
>
>> > There seems to have other bug in this side. From my understanding, com=
mit
>> > 265f94ff54d6(net: Recompute sk_txhash on negative routing advice) trie=
s to
>> > select a different route. But the multipath selection code
>> > (rt6_multipath_select) doesn't use sk_txhash or skb->hash, it does use
>> > fl6.flowlabel, but that is the flowlabel user sets. So looks like the =
commit
>> > doesn't change anything.
>> >
>> The routing functions typically don't use sock of skbuff, but use flow
>> structs instead. It may be reasonable to add a hash to those.
>
> I'll look at this issue later. It's not related to current flowlabel prob=
lem.
>
As I mentioned already, this is not a problem specific to flowlabels.
This is a problem about getting all the elements of the system work
together to ensure that all packets of flow are routed they same way
in order to meet a requirement imposed by middleboxes. You can solve
this problem just to make flow labels work, but IMO that's just
kicking the can down the road for someone else to have to debug and
solve when they hit the same underlying issue but in a different
context.

Tom
