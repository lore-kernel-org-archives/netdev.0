From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: Possible bug in tc tool or kernel
Date: Tue, 17 Mar 2015 23:21:32 +0200
Message-ID: <20150317212132.GA1108@angus-think.lan>
References: <5507FA88.60303@eqv.ru>
 <CAHA+R7O__y1_czX74Ga1RSU-x8X0hUhs2Z01=vo37QUVkNniKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?0KHQvtC70L7QstGM0LXQsiDQodC10YDQs9C10Lk=?= <sol@eqv.ru>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33189 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242AbbCQVdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 17:33:17 -0400
Received: by lbbzq9 with SMTP id zq9so16842682lbb.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 14:33:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7O__y1_czX74Ga1RSU-x8X0hUhs2Z01=vo37QUVkNniKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2015 at 01:42:54PM -0700, Cong Wang wrote:
> On Tue, Mar 17, 2015 at 2:57 AM, =D0=A1=D0=BE=D0=BB=D0=BE=D0=B2=D1=8C=
=D0=B5=D0=B2 =D0=A1=D0=B5=D1=80=D0=B3=D0=B5=D0=B9 <sol@eqv.ru> wrote:
> > Hi!
> >
> > I'm sol sorry, but English in not my native language.
> >
> > After upgrade kernel  tc lost some u32 filters
> >
> > example: where is a "match ip dst 10.10.0.0/24" entries?
> >
>=20
> Can you check if the following commit fixes your problem?
>=20
> It is already merged in stable kernel, you probably need to
> wait for a newer Fedora kernel release if it has included it.
>=20
> commit b057df24a7536cce6c372efe9d0e3d1558afedf4
> Author: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communications.fr=
>
> Date:   Tue Feb 3 19:05:18 2015 +0100
>=20
>     cls_api.c: Fix dumping of non-existing actions' stats.
>=20
>     In tcf_exts_dump_stats(), ensure that exts->actions is not empty =
before
>     accessing the first element of that list and calling tcf_action_c=
opy_stats()
>     on it.  This fixes some random segvs when adding filters of type
> "basic" with
>     no particular action.
>=20
>     This also fixes the dumping of those "no-action" filters, which m=
ore often
>     than not made calls to tcf_action_copy_stats() fail and consequen=
tly netlink
>     attributes added by the caller to be removed by a call to nla_nes=
t_cancel().
>=20
>     Fixes: 33be62715991 ("net_sched: act: use standard struct list_he=
ad")
>     Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-commun=
ications.fr>
>     Acked-by: Cong Wang <cwang@twopensource.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

I tested on:

	Linux 4.0.0-rc3-ARCH-00130-g4363890 #1 SMP PREEMPT Tue Mar 17 23:11:06=
 EET 2015 x86_64 GNU/Linux

and got this:


$ tc filter list dev lo
filter parent 1: protocol ip pref 10 u32=20
filter parent 1: protocol ip pref 10 u32 fh 209: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 208: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 207: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 206: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 205: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 204: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 203: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 202: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 201: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 200: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 100: ht divisor 256=20
filter parent 1: protocol ip pref 10 u32 fh 100::800 order 2048 key ht =
100 bkt 0 link 200:=20
  match 0a0a0000/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:1:800 order 2048 key ht=
 100 bkt 1 link 201:=20
  match 0a0a0100/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:2:800 order 2048 key ht=
 100 bkt 2 link 202:=20
  match 0a0a0200/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:3:800 order 2048 key ht=
 100 bkt 3 link 203:=20
  match 0a0a0300/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:4:800 order 2048 key ht=
 100 bkt 4 link 204:=20
  match 0a0a0400/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:5:800 order 2048 key ht=
 100 bkt 5 link 205:=20
  match 0a0a0500/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:6:800 order 2048 key ht=
 100 bkt 6 link 206:=20
  match 0a0a0600/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:7:800 order 2048 key ht=
 100 bkt 7 link 207:=20
  match 0a0a0700/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:8:800 order 2048 key ht=
 100 bkt 8 link 208:=20
  match 0a0a0800/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 100:9:800 order 2048 key ht=
 100 bkt 9 link 209:=20
  match 0a0a0900/ffffff00 at 16
    hash mask 000000ff at 16=20
filter parent 1: protocol ip pref 10 u32 fh 800: ht divisor 1=20
filter parent 1: protocol ip pref 10 u32 fh 800::800 order 2048 key ht =
800 bkt 0 link 100:=20
  match 0a0a0000/ffff0000 at 16
    hash mask 0000ff00 at 16=20

Regards,
