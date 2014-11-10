From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: Face some error after applying commit 7dfa4b414d4(net/mlx4_en:
 Code cleanups in tx path)
Date: Mon, 10 Nov 2014 13:40:10 +0800
Message-ID: <20141110054010.GA3224@richard>
References: <20141108025758.GA13875@richard>
 <CANn89i+ekXHJSePzQ0rWx2KKqwYGTrok3-ZZ1RdEygVJcGDqRQ@mail.gmail.com>
 <20141110015933.GB6294@richard>
 <1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:48985 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbaKJFkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 00:40:19 -0500
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 10 Nov 2014 15:40:16 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 931F53578077
	for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 16:40:13 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAA5g8WY31522888
	for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 16:42:08 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAA5eCZx008630
	for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 16:40:12 +1100
Content-Disposition: inline
In-Reply-To: <1415587574.13896.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 09, 2014 at 06:46:14PM -0800, Eric Dumazet wrote:
>On Mon, 2014-11-10 at 09:59 +0800, Wei Yang wrote:
>> On Fri, Nov 07, 2014 at 07:38:15PM -0800, Eric Dumazet wrote:
>> >On Fri, Nov 7, 2014 at 6:57 PM, Wei Yang <weiyang@linux.vnet.ibm.co=
m> wrote:
>> >> Eric and Amir
>> >>
>> >> I am testing the VF on PowerNV platform with 3.18-rc2.
>> >> After applying this patch I face some errors.
>> >>
>> >> First is the compiling error.
>> >>
>> >>     drivers/net/ethernet/mellanox/mlx4//en_tx.c: In function =E2=80=
=98mlx4_en_xmit=E2=80=99:
>> >>     drivers/net/ethernet/mellanox/mlx4//en_tx.c:802:8: error: =E2=
=80=98shinfo=E2=80=99 undeclared (first use in this function)
>> >>             shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
>> >>             ^
>> >>     include/linux/compiler.h:160:42: note: in definition of macro=
 =E2=80=98unlikely=E2=80=99
>> >>      # define unlikely(x) __builtin_expect(!!(x), 0)
>> >>                                               ^
>> >>     drivers/net/ethernet/mellanox/mlx4//en_tx.c:802:8: note: each=
 undeclared identifier is reported only once for each function it appea=
rs in
>> >>             shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
>> >>             ^
>> >>     include/linux/compiler.h:160:42: note: in definition of macro=
 =E2=80=98unlikely=E2=80=99
>> >>      # define unlikely(x) __builtin_expect(!!(x), 0)
>> >>                                               ^
>> >>     make[1]: *** [drivers/net/ethernet/mellanox/mlx4//en_tx.o] Er=
ror 1
>> >>     make: *** [_module_drivers/net/ethernet/mellanox/mlx4/] Error=
 2
>> >>
>> >
>> >
>> >This compilation error seems strange.
>> >
>> >Are you sure your tree is pristine, not corrupted in any way ?
>>=20
>> I believe I did the revert one by one with git revert.
>>=20
>> >
>> >
>> >> I tried to fix this with following change:
>> >>
>> >>     [root@tian-lp1 3.18]# git diff
>> >>     diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/dri=
vers/net/ethernet/m
>> >>     index eaf23eb..d2f06a7 100644
>> >>     --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> >>     +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> >>     @@ -799,8 +799,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *=
skb, struct net_dev
>> >>              * set flag for further reference
>> >>              */
>> >>             if (unlikely(ring->hwtstamp_tx_type =3D=3D HWTSTAMP_T=
X_ON &&
>> >>     -                    shinfo->tx_flags & SKBTX_HW_TSTAMP)) {
>> >>     -               shinfo->tx_flags |=3D SKBTX_IN_PROGRESS;
>> >>     +                    skb_shinfo(skb)->tx_flags & SKBTX_HW_TST=
AMP)) {
>> >>     +               skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGR=
ESS;
>> >>                     tx_info->ts_requested =3D 1;
>> >>             }
>> >>
>> >> But seems to face another error.
>> >>
>> >
>> >I suspect your tree is not the official tree, I do not see how you =
got
>> >this compilation error.
>>=20
>>=20
>> I checked the upstream git tree again, and find this commit:
>>=20
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3D7dfa4b414d4eec8da56e44fb2b4aea3e549b092f
>>=20
>>=20
>> And I want to say the shinfo local variable is introduced in commit:
>>=20
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3Db9d8839a44092cb4268ef2813c34d5dbf3363603
>>=20
>> And in my log tree, also checked the upstream, this one is applyed a=
fter the
>> first one. And the compiling error will disappear untill I apply thi=
s one.
>>=20
>> So this compiling issue can't reproduced at your side? You have rese=
t --hard
>> to the "Code cleanup" one, and can't see the error? That is strange.
>>=20
>
>Okay, your message was not clear : I thought you had a compilation err=
or
>on current tree.
>
>The true story of these patches is that Mellanox split an initial big
>chunk [1] I gave into multiple patches.
>
>Maybe they missed that one patch did not actually compile.
>
>[1] https://patchwork.ozlabs.org/patch/394256/
>
>Now, it is done, there is nothing we can do.
>
>I'll let Mellanox comment, but it looks like your hardware does not li=
ke
>something.
>
>Have you tried to disable Blue Frame ?
>

Yep, looks the PF works fine. But the current FW I can't just enable th=
e PF.

How to disable Blue Frame? I am not clear about this.


--=20
Richard Yang
Help you, Help me
