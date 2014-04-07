From: Kelly Anderson <kelly@xilka.com>
Subject: Re: 3.14 tc oops
Date: Mon, 07 Apr 2014 04:16:40 -0600
Message-ID: <2789862.sUpXpBjVD1@comer>
References: <1592838.91HrDxMk9i@comer> <CAM_iQpVgEtDqbK6-JoMn8-1D_cOsRTGPozvbmxbCBKi1+ss-rQ@mail.gmail.com> <CAM_iQpU+A+1FxFNkibvbkM=vkWVw7QmHJzE_AODVTgzUEjdeDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart2684077.yApzBqztfJ"
Content-Transfer-Encoding: 7Bit
Cc: Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ar100.montanavision.com ([216.146.103.100]:52807 "EHLO
	xilka.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbaDGKZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 06:25:52 -0400
In-Reply-To: <CAM_iQpU+A+1FxFNkibvbkM=vkWVw7QmHJzE_AODVTgzUEjdeDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart2684077.yApzBqztfJ
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Cong,

The patch did not fix the problem.

For your convenience, I've attached tc filter show for eth0 and eth1, as well 
as a mangled version of my tcng input file.



On Sunday, April 06, 2014 22:56:27 you wrote:
> On Thu, Apr 3, 2014 at 9:24 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Wed, Apr 2, 2014 at 7:24 AM, Kelly Anderson <kelly@xilka.com> wrote:
> >> Hi,
> >> 
> >> I hit a kernel oops when starting traffic control on my armv7 router, I
> >> don't think the architecture is related, the same tc code worked
> >> perfectly with earlier kernel versions, i.e. 3.13.x.
> >> 
> >> I also attached an object dump with line numbers to make identifying the
> >> problem a bit easier.
> >> 
> >> Please cc me to keep me in the loop, I can test patches.
> > 
> > Thanks for the report! Looks like it is caused by one of my patches,
> > I will look into this shortly.
> 
> Which tc filter are you using on that htb qdisc? (tc filter show dev ....)
> 
> I suspect it's tcindex filter, if so please try the following patch:
> 
> diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
> index eed8404..14618cc 100644
> --- a/net/sched/cls_tcindex.c
> +++ b/net/sched/cls_tcindex.c
> @@ -298,8 +298,10 @@ tcindex_set_parms(struct net *net, struct
> tcf_proto *tp, unsigned long base,
>         tcf_exts_change(tp, &cr.exts, &e);
> 
>         tcf_tree_lock(tp);
> -       if (old_r && old_r != r)
> +       if (old_r && old_r != r) {
>                 memset(old_r, 0, sizeof(*old_r));
> +               tcf_exts_init(&old_r->exts, TCA_TCINDEX_ACT,
> TCA_TCINDEX_POLICE);
> +       }
> 
>         memcpy(p, &cp, sizeof(cp));
>         memcpy(r, &cr, sizeof(cr));
--nextPart2684077.yApzBqztfJ
Content-Disposition: attachment; filename="tc-filter-show-eth0.txt"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"; name="tc-filter-show-eth0.txt"

filter parent 1: protocol all pref 1 u32 
filter parent 1: protocol all pref 1 u32 fh 16: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 16::1 order 1 key ht 16 bkt 0 flowid 1:3 
  match 0c380000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 15: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 15::1 order 1 key ht 15 bkt 0 flowid 1:3 
  match 0c380000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 14: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 14::1 order 1 key ht 14 bkt 0 flowid 1:3 
  match 00004762/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 13: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 13::1 order 1 key ht 13 bkt 0 flowid 1:3 
  match 00004762/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 12: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 12::1 order 1 key ht 12 bkt 0 flowid 1:3 
  match 00004763/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 11: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 11::1 order 1 key ht 11 bkt 0 flowid 1:3 
  match 00004763/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 10: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 10::1 order 1 key ht 10 bkt 0 flowid 1:3 
  match 00004764/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh f: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh f::1 order 1 key ht f bkt 0 flowid 1:3 
  match 00004764/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh e: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh e::1 order 1 key ht e bkt 0 flowid 1:3 
  match 24ca0000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh d: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh d::1 order 1 key ht d bkt 0 flowid 1:3 
  match 078f0000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh c: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh c::1 order 1 key ht c bkt 0 flowid 1:3 
  match 01bb0000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh b: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh b::1 order 1 key ht b bkt 0 flowid 1:3 
  match 1f900000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh a: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh a::1 order 1 key ht a bkt 0 flowid 1:3 
  match 00500000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 9: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 9::1 order 1 key ht 9 bkt 0 flowid 1:1 
  match 00007fff/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 8: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 8::1 order 1 key ht 8 bkt 0 flowid 1:1 
  match 00007ffd/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 7: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 7::1 order 1 key ht 7 bkt 0 flowid 1:1 
  match 00000801/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 6: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 6::1 order 1 key ht 6 bkt 0 flowid 1:1 
  match 00000016/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 5: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 5::1 order 1 key ht 5 bkt 0 flowid 1:1 
  match 00160000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 4: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 4::1 order 1 key ht 4 bkt 0 flowid 1:1 
  match 00001389/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 3: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 3::1 order 1 key ht 3 bkt 0 flowid 1:1 
  match 13890000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 2: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 2::1 order 1 key ht 2 bkt 0 flowid 1:1 
  match 00350000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 1: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 1::1 order 1 key ht 1 bkt 0 flowid 1:1 
  match 00350000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 800: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1 
  match 00010000/00ff0000 at 8
filter parent 1: protocol all pref 1 u32 fh 800::801 order 2049 key ht 800 bkt 0 flowid 1:1 
  match 00100000/00ff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 800::802 order 2050 key ht 800 bkt 0 link 1: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::803 order 2051 key ht 800 bkt 0 link 2: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::804 order 2052 key ht 800 bkt 0 link 3: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::805 order 2053 key ht 800 bkt 0 link 4: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::806 order 2054 key ht 800 bkt 0 link 5: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::807 order 2055 key ht 800 bkt 0 link 6: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::808 order 2056 key ht 800 bkt 0 link 7: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::809 order 2057 key ht 800 bkt 0 link 8: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80a order 2058 key ht 800 bkt 0 link 9: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80b order 2059 key ht 800 bkt 0 flowid 1:2 
  match c0a80109/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::80c order 2060 key ht 800 bkt 0 link a: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80d order 2061 key ht 800 bkt 0 link b: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80e order 2062 key ht 800 bkt 0 link c: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80f order 2063 key ht 800 bkt 0 link d: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::810 order 2064 key ht 800 bkt 0 link e: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::811 order 2065 key ht 800 bkt 0 link f: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::812 order 2066 key ht 800 bkt 0 link 10: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::813 order 2067 key ht 800 bkt 0 link 11: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::814 order 2068 key ht 800 bkt 0 link 12: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::815 order 2069 key ht 800 bkt 0 link 13: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::816 order 2070 key ht 800 bkt 0 link 14: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::817 order 2071 key ht 800 bkt 0 flowid 1:3 
  match c0a80200/ffffff00 at 12
filter parent 1: protocol all pref 1 u32 fh 800::818 order 2072 key ht 800 bkt 0 flowid 1:3 
  match c0a80119/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::819 order 2073 key ht 800 bkt 0 flowid 1:3 
  match c0a80130/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::81a order 2074 key ht 800 bkt 0 flowid 1:3 
  match c0a80131/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::81b order 2075 key ht 800 bkt 0 flowid 1:3 
  match c0a80133/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::81c order 2076 key ht 800 bkt 0 flowid 1:3 
  match c0a80135/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::81d order 2077 key ht 800 bkt 0 flowid 1:3 
  match c0a8013c/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::81e order 2078 key ht 800 bkt 0 flowid 1:3 
  match c0a80171/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::81f order 2079 key ht 800 bkt 0 flowid 1:3 
  match c0a8012e/ffffffff at 16
filter parent 1: protocol all pref 1 u32 fh 800::820 order 2080 key ht 800 bkt 0 flowid 1:3 
  match 20010470/ffffffff at 24
  match 1f1105a5/ffffffff at 28
  match 821f02ff/ffffffff at 32
  match fe943d9d/ffffffff at 36
filter parent 1: protocol all pref 1 u32 fh 800::821 order 2081 key ht 800 bkt 0 flowid 1:3 
  match 20010470/ffffffff at 24
  match 1f1105a5/ffffffff at 28
  match 02012eff/ffffffff at 32
  match fe4c710e/ffffffff at 36
filter parent 1: protocol all pref 1 u32 fh 800::822 order 2082 key ht 800 bkt 0 link 15: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::823 order 2083 key ht 800 bkt 0 link 16: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::824 order 2084 key ht 800 bkt 0 flowid 1:4 
  match 00000000/00000000 at 0

--nextPart2684077.yApzBqztfJ
Content-Disposition: attachment; filename="tc-filter-show-eth1.txt"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"; name="tc-filter-show-eth1.txt"

filter parent 1: protocol all pref 1 u32 
filter parent 1: protocol all pref 1 u32 fh 11: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 11::1 order 1 key ht 11 bkt 0 flowid 1:3 
  match 00000000/ffffffff at 8
filter parent 1: protocol all pref 1 u32 fh 10: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 10::1 order 1 key ht 10 bkt 0 flowid 1:2 
  match 00001194/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh f: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh f::1 order 1 key ht f bkt 0 flowid 1:2 
  match 11940000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh e: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh e::1 order 1 key ht e bkt 0 flowid 1:2 
  match 00000035/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh d: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh d::1 order 1 key ht d bkt 0 flowid 1:2 
  match 006e0000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh c: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh c::1 order 1 key ht c bkt 0 flowid 1:2 
  match 47620000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh b: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh b::1 order 1 key ht b bkt 0 flowid 1:2 
  match 47620000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh a: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh a::1 order 1 key ht a bkt 0 flowid 1:2 
  match 47630000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 9: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 9::1 order 1 key ht 9 bkt 0 flowid 1:2 
  match 47630000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 8: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 8::1 order 1 key ht 8 bkt 0 flowid 1:2 
  match 47640000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 7: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 7::1 order 1 key ht 7 bkt 0 flowid 1:2 
  match 47640000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 6: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 6::1 order 1 key ht 6 bkt 0 flowid 1:2 
  match 000024ca/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 5: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 5::1 order 1 key ht 5 bkt 0 flowid 1:2 
  match 0000078f/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 4: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 4::1 order 1 key ht 4 bkt 0 flowid 1:2 
  match 000001bb/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 3: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 3::1 order 1 key ht 3 bkt 0 flowid 1:2 
  match 00001f90/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 2: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 2::1 order 1 key ht 2 bkt 0 flowid 1:2 
  match 00000050/0000ffff at 0
filter parent 1: protocol all pref 1 u32 fh 1: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 1::1 order 1 key ht 1 bkt 0 flowid 1:1 
  match 00500000/ffff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 800: ht divisor 1 
filter parent 1: protocol all pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 link 1: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::801 order 2049 key ht 800 bkt 0 flowid 1:1 
  match 00290000/00ff0000 at 8
  match bb810000/ffff0000 at 60
filter parent 1: protocol all pref 1 u32 fh 800::802 order 2050 key ht 800 bkt 0 flowid 1:2 
  match 00010000/00ff0000 at 8
filter parent 1: protocol all pref 1 u32 fh 800::803 order 2051 key ht 800 bkt 0 link 2: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::804 order 2052 key ht 800 bkt 0 link 3: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::805 order 2053 key ht 800 bkt 0 link 4: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::806 order 2054 key ht 800 bkt 0 link 5: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::807 order 2055 key ht 800 bkt 0 link 6: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::808 order 2056 key ht 800 bkt 0 flowid 1:2 
  match 00100000/00ff0000 at 0
filter parent 1: protocol all pref 1 u32 fh 800::809 order 2057 key ht 800 bkt 0 link 7: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80a order 2058 key ht 800 bkt 0 link 8: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80b order 2059 key ht 800 bkt 0 link 9: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80c order 2060 key ht 800 bkt 0 link a: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80d order 2061 key ht 800 bkt 0 link b: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80e order 2062 key ht 800 bkt 0 link c: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::80f order 2063 key ht 800 bkt 0 link d: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::810 order 2064 key ht 800 bkt 0 link e: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::811 order 2065 key ht 800 bkt 0 link f: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::812 order 2066 key ht 800 bkt 0 link 10: 
  match 00110000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::813 order 2067 key ht 800 bkt 0 flowid 1:2 
  match c0a80119/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::814 order 2068 key ht 800 bkt 0 flowid 1:2 
  match c0a80130/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::815 order 2069 key ht 800 bkt 0 flowid 1:2 
  match c0a80131/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::816 order 2070 key ht 800 bkt 0 flowid 1:2 
  match c0a80133/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::817 order 2071 key ht 800 bkt 0 flowid 1:2 
  match c0a80135/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::818 order 2072 key ht 800 bkt 0 flowid 1:2 
  match c0a8013c/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::819 order 2073 key ht 800 bkt 0 flowid 1:2 
  match c0a80171/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::81a order 2074 key ht 800 bkt 0 flowid 1:2 
  match c0a8012e/ffffffff at 12
filter parent 1: protocol all pref 1 u32 fh 800::81b order 2075 key ht 800 bkt 0 flowid 1:2 
  match 00290000/00ff0000 at 8
  match 20010470/ffffffff at 28
  match 1f1105a5/ffffffff at 32
  match 821f02ff/ffffffff at 36
  match fe943d9d/ffffffff at 40
filter parent 1: protocol all pref 1 u32 fh 800::81c order 2076 key ht 800 bkt 0 flowid 1:2 
  match 00290000/00ff0000 at 8
  match 20010470/ffffffff at 28
  match 1f1105a5/ffffffff at 32
  match 02012eff/ffffffff at 36
  match fe4c710e/ffffffff at 40
filter parent 1: protocol all pref 1 u32 fh 800::81d order 2077 key ht 800 bkt 0 link 11: 
  match 00060000/00ff0000 at 8
    offset 0f00>>6 at 0  eat 
filter parent 1: protocol all pref 1 u32 fh 800::81e order 2078 key ht 800 bkt 0 flowid 1:2 
  match 00060000/00ff0000 at 8
filter parent 1: protocol all pref 1 u32 fh 800::81f order 2079 key ht 800 bkt 0 flowid 1:3 
  match 00000000/00000000 at 0

--nextPart2684077.yApzBqztfJ
Content-Disposition: attachment; filename="idle-mangle.tcc"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-csrc; charset="utf-8"; name="idle-mangle.tcc"

/*
 * tcng standard rate control
 * script for traffic
 * specifically limits outgoing web server
 * and outgoing torrent bandwidth
 */

#define SKYPE_RATE 90

#define INTERNAL_INTERFACE "eth0"
#define EXTERNAL_INTERFACE "eth1"

#define PORT_SSH 22
#define PORT_DNS 53
#define PORT_HTTP 80
#define PORT_HTTP_ALT 8080
#define PORT_HTTPS 443
#define PORT_POP 110
#define PORT_RTMP 1935
#define PORT_RTMP_PROXY 8888
#define PORT_NFS 2049
#define PORT_SQUID 3128
#define PORT_IPSEC 4500
#define PORT_IPERF 5001
#define PORT_GIT 9418
#define PORT_SKYPE_HOST1 18274
#define PORT_SKYPE_HOST11 18275
#define PORT_SKYPE_HOST6 18276
#define PORT_STATD_IN 32765
#define PORT_STATD_OUT 32766
#define PORT_MOUNTD 32767
#define PORT_TORRENT_HOST11 32110
#define PORT_TORRENT_HOST2 32111
#define IP_FW1_EXTERNAL 192.168.222.254
#define IP_HOST2 192.168.211.9
#define IP_HOST12  192.168.211.25
#define IP_HOST3  192.168.211.46
#define IP_HOST7 192.168.211.48
#define IP_HOST8 192.168.211.49
#define IP_HOST4    192.168.211.51
#define IP_HOST5   192.168.211.53
#define IP_HOST9    192.168.211.60
#define IP_HOST10   192.168.211.113
#define IP6_HOST4   2001:388:1e44:432:821f:2ff:fe2c:3d9d
#define IP6_HOST3 2001:388:1e44:432:201:2eff:fe4c:710e

/*#define IP_SUBNET2 192.168.2.0/24*/
#define IP_SUBNET2 192.168.2.0

#define IP_HURRICANE_ELECTRIC 213.188.122.111

#define IPPROTO_6IN4 41
//field ip_proto_6in4 = ip_hdr[9].b;		/* protocol */
field tc_6in4 = (raw[20].ns >> 4) & 0xff; /* traffic class */

field ip6_src_6in4 = raw[28].ipv6;
field ip6_dst_6in4 = raw[44].ipv6;
/* 6in4 next header starts at 60 */
field udp_sport_6in4 = raw[60].ns;
field udp_dport_6in4 = raw[62].ns;

dev EXTERNAL_INTERFACE {
	egress
	{
#if 0
		class ( <$high> )
			if ip_dst == IP_HURRICANE_ELECTRIC;
#endif

		class ( <$medium> )
			if (tcp_sport == PORT_HTTP)
				|| (ip_proto == IPPROTO_6IN4
					&& udp_sport_6in4 == PORT_TORRENT_HOST2);

		class ( <$high> )
			if ip_proto == IPPROTO_ICMP
				|| tcp_dport == PORT_HTTP
				|| tcp_dport == PORT_HTTP_ALT
				|| tcp_dport == PORT_HTTPS
				|| tcp_dport == PORT_RTMP
				|| tcp_dport == PORT_GIT
				|| ip_tos == 0x10
				|| tcp_sport == PORT_SKYPE_HOST6
				|| udp_sport == PORT_SKYPE_HOST6
				|| tcp_sport == PORT_SKYPE_HOST11
				|| udp_sport == PORT_SKYPE_HOST11
				|| tcp_sport == PORT_SKYPE_HOST1
				|| udp_sport == PORT_SKYPE_HOST1
				|| tcp_sport == PORT_POP
				|| udp_dport == PORT_DNS
				|| udp_sport == PORT_IPSEC
				|| udp_dport == PORT_IPSEC
				|| ip_src == IP_HOST12
				|| ip_src == IP_HOST7
				|| ip_src == IP_HOST8
				|| ip_src == IP_HOST4
				|| ip_src == IP_HOST5
				|| ip_src == IP_HOST9
				|| ip_src == IP_HOST10
				|| ip_src == IP_HOST3
				|| (ip_proto == IPPROTO_6IN4
					&& ip6_src_6in4 == IP6_HOST4)
				|| (ip_proto == IPPROTO_6IN4
					&& ip6_src_6in4 == IP6_HOST3)
				|| tcp_ack;

			class ( <$low> )
				if 1;

		htb ( r2q 20 )
		{
			class ( rate 900 kbps )
			{
				class ( prio 1, rate 900 kbps )
				{
					$high = class ( prio 1, rate 500 kbps, ceil 900 kbps )
						{ sfq ( perturb 10 sec ); };

					$medium = class (prio 2, rate 300 kbps, ceil 750 kbps )
						{ sfq ( perturb 10 sec ); };

					$low = class (prio 3, rate  100 kbps, ceil 200 kbps )
						{ sfq ( perturb 10 sec ); };
				}
			}
		}
	}
}

dev INTERNAL_INTERFACE {
	egress
	{
		class ( <$interactive> )
			if ip_proto == IPPROTO_ICMP
				|| ip_tos == 0x10
				|| udp_sport == PORT_DNS
				|| tcp_sport == PORT_DNS
				|| tcp_sport == PORT_IPERF
				|| tcp_dport == PORT_IPERF
				|| tcp_sport == PORT_SSH
				|| tcp_dport == PORT_SSH
				|| tcp_dport == PORT_NFS
				|| tcp_dport == PORT_STATD_IN
				|| tcp_dport == PORT_MOUNTD;
				//|| tcp_ack;

#if 0
		class ( <$high> )
			if meta_protocol == ETH_P_IPV6;
#endif

		class ( <$medium> )
			if ip_dst == IP_HOST2;

		class ( <$high> )
			if tcp_sport == PORT_HTTP
				|| tcp_sport == PORT_HTTP_ALT
				|| tcp_sport == PORT_HTTPS
				|| tcp_sport == PORT_RTMP
				|| tcp_sport == PORT_GIT
				|| tcp_dport == PORT_SKYPE_HOST6
				|| udp_dport == PORT_SKYPE_HOST6
				|| tcp_dport == PORT_SKYPE_HOST11
				|| udp_dport == PORT_SKYPE_HOST11
				|| tcp_dport == PORT_SKYPE_HOST1
				|| udp_dport == PORT_SKYPE_HOST1
				|| ip_src:24 == IP_SUBNET2
				|| ip_dst == IP_HOST12
				|| ip_dst == IP_HOST7
				|| ip_dst == IP_HOST8
				|| ip_dst == IP_HOST4
				|| ip_dst == IP_HOST5
				|| ip_dst == IP_HOST9
				|| ip_dst == IP_HOST10
				|| ip_dst == IP_HOST3
				|| ip6_dst == IP6_HOST4
				|| ip6_dst == IP6_HOST3
				|| tcp_sport == PORT_SQUID
				|| udp_sport == PORT_SQUID;

		class ( <$low> )
			if 1;

		htb ( r2q 250 )
		{
			class ( rate 900 Mbps )
			{
				$interactive = class ( prio 1, rate 800 Mbps )
				{ sfq ( perturb 10 sec ); };

				class ( prio 1, rate 10 Mbps )
				{
					$high = class ( prio 1, rate 6 Mbps, ceil 10 Mbps )
					{ sfq ( perturb 10 sec ); };

					$medium = class (prio 2, rate 2 Mbps, ceil 4 Mbps )
					{ sfq ( perturb 10 sec ); };

					$low = class (prio 3, rate 2 Mbps, ceil 3 Mbps )
					{ sfq ( perturb 10 sec ); };
				}
			}
		}
	}
}


--nextPart2684077.yApzBqztfJ--
