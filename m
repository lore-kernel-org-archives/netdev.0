From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc -d class show dev <device_name> ' command
Date: Thu, 17 Dec 2015 12:27:41 +0300
Message-ID: <740111450344461@web24h.yandex.ru>
References: <5917221449918579@web5j.yandex.ru> <20151216161558.265296c7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Phil Sutter <psutter@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward19h.cmail.yandex.net ([87.250.230.161]:58715 "EHLO
	forward19h.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751434AbbLQJfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 04:35:16 -0500
In-Reply-To: <20151216161558.265296c7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

16.12.2015, 18:16, "Jesper Dangaard Brouer" <brouer@redhat.com>:

> =9AI don't think your patch should contain this cleanup of "b4".
> =9ASubmit another patch with that cleanup change, please.
>
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Aif (show_de=
tails) {
>> =9A=9A- fprintf(f, "burst %s/%u mpu %s overhead %s ",
>> =9A=9A+ fprintf(f, "burst %s/%u mpu %s ",
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Asprint_size(buffer, b1),
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A1<<hopt->rate.cell_log,
>> =9A=9A- sprint_size(hopt->rate.mpu&0xFF, b2),
>> =9A=9A- sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
>> =9A=9A- fprintf(f, "cburst %s/%u mpu %s overhead %s ",
>> =9A=9A+ sprint_size(hopt->rate.mpu, b2));
>> =9A=9A+ fprintf(f, "cburst %s/%u mpu %s ",
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Asprint_size(cbuffer, b1),
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A1<<hopt->ceil.cell_log,
>> =9A=9A- sprint_size(hopt->ceil.mpu&0xFF, b2),
>> =9A=9A- sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));
>> =9A=9A+ sprint_size(hopt->ceil.mpu, b2));
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9Afprintf(f, "level %d ", (int)hopt->level);
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A} else {
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9Afprintf(f, "burst %s ", sprint_size(buffer, b1));


Ok, but I don't see any other usage of b4:

administrator@UX32LN:~/Sources/iproute2/tc$ git branch
* (HEAD detached at 654ae88)
=9A=9Amaster
=9A=9Av3.18.0


16.12.2015, 18:16, "Jesper Dangaard Brouer" <brouer@redhat.com>:
> Hi Dmitrii,
>
> On Sat, 12 Dec 2015 14:09:39 +0300 Dmitrii Shcherbakov <fw.dmitrii@ya=
ndex.com> wrote:
>
>> =9AI noticed a quite an old change which I have a few questions abou=
t so
>> =9Amaybe somebody could help me out. There are a few lines of code i=
n
>> =9Atc/q_htb.c which were committed originally back in 2004 and have =
not
>> =9Achanged since related to MPU (Minimum Packet Unit). I asked Steph=
en -
>> =9Athis is probably the code that pre-dated git so I am not sure exa=
ctly
>> =9Awho to ask:
>
> AFAIKR I was involved in these overhead changes back in 2004, and als=
o
> around 2007 where we introduced a "real" overhead parameter.
>
> We "moved" the overhead parameter to be a "real" struct member (in my=
 commit
> e08b09983fe9 ("[NET_SCHED]: Making rate table lookups more flexible."=
))
>
> Thus, this encoding of overhead in the "mpu" should be obsolete.
>
> struct tc_ratespec {
> =9A=9A=9A=9A=9A=9A=9A=9Aunsigned char cell_log;
> =9A=9A=9A=9A=9A=9A=9A=9A__u8 linklayer; /* lower 4 bits */
> =9A=9A=9A=9A=9A=9A=9A=9Aunsigned short overhead;
> =9A=9A=9A=9A=9A=9A=9A=9Ashort cell_align;
> =9A=9A=9A=9A=9A=9A=9A=9Aunsigned short mpu;
> =9A=9A=9A=9A=9A=9A=9A=9A__u32 rate;
> };
>
> (sometimes accessed via struct qdisc_rate_table->rate.overhead)
>
> In newer kernels, this tc_ratespec, is converted and transfered to
> struct psched_ratecfg (in functions psched_ratecfg_precompute() and
> psched_ratecfg_getrate()).
>
>> =9AI noticed that there is a separate configurable value called
>> =9A'overhead' in q_htb.c now which does not have anything to do with
>> =9A'overhead =3D hopt->rate.mpu>>8)&0xFF' that is being printed out =
in the
>> =9Aabove lines:
>
> Looking through both the kernel and iproute2 code, it looks like only
> the "real" overhead is used. I cannot find any users of the encoded
> overhead into the mpu value. Thus, your patch should be okay...
>
>> =9Astatic void explain(void)
>> =9A{
>> =9A=9A=9A=9A=9A...
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A" overhead per-packet size overhead used =
in rate computations\n"
>> =9A=9A=9A=9A=9A...
>
>> =9AIn the code fragment from the commit (for some reason I don't
>> =9Aunderstand) 'rate.mpu' is sliced into two parts called 'mpu' and
>> =9A'overhead'. So, basically, to retrieve the original MPU value fro=
m
>> =9Athe output of `tc -d class show dev <device_name>` I need to do t=
he
>> =9Afollowing: real_mpu =3D mpu + overhead<<8.
>
>> =9AI also have a hard time understanding whether it is possible to h=
ave
>> =9Aa condition where rate.mpu and ceil.mpu have different values - t=
he
>> =9Aoutputs I have seen always showed the same values for both and I =
do
>> =9Anot see anything in the code that sets them to different values (=
if
>> =9Aso, maybe the duplicate output should be removed).
>
> Maybe. But do consider backwards compat issues,if you have this outpu=
t
> (e.g. like scripts parsing this output).
>
> When trying to understand this code, keep in mind that we are trying
> to keep backward compatible with older kernels. Thus, this printing
> might be have been left here to keep compat with older kernels, but I
> think we can remove it now.
>
>> =9APlease take a look at my patch if you have time for it as this wo=
uld
>> =9Asimplify testing in the project I work on and make the output of =
the
>> =9Acommand less ambiguous for other people who may use HTB.
>
> Reviewed below
>
>> =9AThank you,
>> =9ADmitrii Shcherbakov
>>
>> =9AFrom 26c62f17e1d6ebca9f236000806a63363ab70640 Mon Sep 17 00:00:00=
 2001
>> =9AFrom: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
>> =9ADate: Sat, 12 Dec 2015 02:04:09 +0300
>> =9ASubject: [PATCH] tc/q_htb.c: Fix the MPU value output in 'tc -d c=
lass show dev
>> =9A=9A<device_name> ' command
>>
>> =9AThis patch removes slicing of 'rate.mpu' into two parts called 'm=
pu'
>> =9Aand 'overhead' alleviating the need to perform calculations to ge=
t
>> =9Athe original MPU value after it is configured as follows: real_mp=
u =3D
>> =9Ampu + overhead<<8.
>>
>> =9ASigned-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
>> =9A---
>> =9A=9Atc/q_htb.c | 13 +++++--------
>> =9A=9A1 file changed, 5 insertions(+), 8 deletions(-)
>>
>> =9Adiff --git a/tc/q_htb.c b/tc/q_htb.c
>> =9Aindex 7075a4c..f810329 100644
>> =9A--- a/tc/q_htb.c
>> =9A+++ b/tc/q_htb.c
>> =9A@@ -274,7 +274,6 @@ static int htb_print_opt(struct qdisc_util *q=
u, FILE *f, struct rtattr *opt)
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9ASPRINT_BUF(b1);
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9ASPRINT_BUF(b2);
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9ASPRINT_BUF(b3);
>> =9A- SPRINT_BUF(b4);
>>
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9Aif (opt =3D=3D NULL)
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Areturn 0;
>> =9A@@ -311,18 +310,16 @@ static int htb_print_opt(struct qdisc_util =
*qu, FILE *f, struct rtattr *opt)
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Acbuffer =3D tc=
_calc_xmitsize(ceil64, hopt->cbuffer);
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Alinklayer =3D =
(hopt->rate.linklayer & TC_LINKLAYER_MASK);
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Aif (linklayer =
> TC_LINKLAYER_ETHERNET || show_details)
>> =9A- fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));
>> =9A+ fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b3));
>
> I don't think your patch should contain this cleanup of "b4".
> Submit another patch with that cleanup change, please.
>
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Aif (show_detai=
ls) {
>> =9A- fprintf(f, "burst %s/%u mpu %s overhead %s ",
>> =9A+ fprintf(f, "burst %s/%u mpu %s ",
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Asprint_size(buffer, b1),
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A1<<hopt->rate.cell_log,
>> =9A- sprint_size(hopt->rate.mpu&0xFF, b2),
>> =9A- sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
>> =9A- fprintf(f, "cburst %s/%u mpu %s overhead %s ",
>> =9A+ sprint_size(hopt->rate.mpu, b2));
>> =9A+ fprintf(f, "cburst %s/%u mpu %s ",
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Asprint_size(cbuffer, b1),
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A1<<hopt->ceil.cell_log,
>> =9A- sprint_size(hopt->ceil.mpu&0xFF, b2),
>> =9A- sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));
>> =9A+ sprint_size(hopt->ceil.mpu, b2));
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9Afprintf(f, "level %d ", (int)hopt->level);
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A} else {
>> =9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=
=9A=9A=9Afprintf(f, "burst %s ", sprint_size(buffer, b1));
>
> Other part of patch looks good.
>
> Please resubmit patch "officially" and Cc me, then I will review and =
ACK.
> --
> Best regards,
> =9A=9AJesper Dangaard Brouer
> =9A=9AMSc.CS, Principal Kernel Engineer at Red Hat
> =9A=9AAuthor of http://www.iptv-analyzer.org
> =9A=9ALinkedIn: http://www.linkedin.com/in/brouer
