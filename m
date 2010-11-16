From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 07:31:51 +0800
Message-ID: <AANLkTi=-Kr7OpSSz1aTQxTEwaOwf_m6hPDr24vYw_z75@mail.gmail.com>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
 <20101110.102129.112602843.davem@davemloft.net> <1289414024.2469.20.camel@edumazet-laptop>
 <20101110.103807.39173013.davem@davemloft.net> <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
 <20101116221310.GA3058@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	davem@davemloft.net, eric.dumazet@gmail.com,
	drosenberg@vsecurity.com, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:63351 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932745Ab0KPXcM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 18:32:12 -0500
Received: by ewy8 with SMTP id 8so813298ewy.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 15:32:11 -0800 (PST)
In-Reply-To: <20101116221310.GA3058@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 17, 2010 at 6:13 AM, Hagen Paul Pfeifer <hagen@jauu.net> wr=
ote:
> * Tetsuo Handa | 2010-11-16 22:08:50 [+0900]:
>
>>--- a/net/core/filter.c
>>+++ b/net/core/filter.c
>>@@ -383,7 +383,57 @@ EXPORT_SYMBOL(sk_run_filter);
>> =A0*/
>> int sk_chk_filter(struct sock_filter *filter, int flen)
>> {
>>- =A0 =A0 =A0struct sock_filter *ftest;
>>+ =A0 =A0 =A0/*
>>+ =A0 =A0 =A0 * Valid instructions are initialized to non-0.
>>+ =A0 =A0 =A0 * Invalid instructions are initialized to 0.
>>+ =A0 =A0 =A0 */
>>+ =A0 =A0 =A0static u16 codes[] =3D {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0[BPF_ALU|BPF_ADD|BPF_K] =A0=3D BPF_S_ALU=
_ADD_K + 1,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0[BPF_ALU|BPF_ADD|BPF_X] =A0=3D BPF_S_ALU=
_ADD_X + 1,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0[BPF_ALU|BPF_SUB|BPF_K] =A0=3D BPF_S_ALU=
_SUB_K + 1,
> [...]
>
> Maybe I don't get it, but you increment the opcode by one, but you ne=
ver
> increment the opcode in sk_run_filter() - do I miss something? Did yo=
u test
> the your patch (a trivial tcpdump rule should be sufficient)?
>

+               code =3D codes[code];
+               if (!code--)
+                       return -EINVAL;

But how about this:

enum {
        BPF_S_RET_K =3D 1,

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
