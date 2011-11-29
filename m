From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Tue, 29 Nov 2011 11:32:42 +0100
Message-ID: <CAFdo_mXp9a_e4YWc5C12HFqLhqv-LY+MoDvEbfz=Ts6Cg5rbdA@mail.gmail.com>
References: <igorm@etf.rs>
	<1322511796-6908-1-git-send-email-igorm@etf.rs>
	<1322511796-6908-2-git-send-email-igorm@etf.rs>
	<1322512426.2970.15.camel@edumazet-laptop>
	<1322515010.2970.24.camel@edumazet-laptop>
	<fba9911084786bf04747c0350e774615.squirrel@kondor.etf.bg.ac.rs>
	<1322559093.2970.102.camel@edumazet-laptop>
	<88caa73892721f74b81e72c1ff1a0be3.squirrel@kondor.etf.bg.ac.rs>
	<1322562450.2285.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:39859 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919Ab1K2Kcr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 05:32:47 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 5DFC16012E
	for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 11:32:45 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id NryNtOGWSeJF for <netdev@vger.kernel.org>;
	Tue, 29 Nov 2011 11:32:44 +0100 (CET)
Received: from mail-gy0-f174.google.com (mail-gy0-f174.google.com [209.85.160.174])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id 5651C1200EC
	for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 11:32:44 +0100 (CET)
Received: by ghrr1 with SMTP id r1so6210055ghr.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 02:32:42 -0800 (PST)
In-Reply-To: <1322562450.2285.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry,
just send another without using your remarks...
Thaks
Will listen to you in future.
BR
Igor

2011/11/29 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 29 novembre 2011 =C3=A0 10:48 +0100, "Igor Maravi=C4=87" a =C3=
=A9crit :
>
>>
>> PS. Tested the patch - it works.
>>
>> [PATCH 1/1] Warning if_interrupt is true
>
> Few remarks, since you start to send official patches ;)
>
> - Since its not a serie of several patches, you dont need the 1/1
> - Since tree is net-next, not net, you should say it to David
> - We need a better title, with subsystem: tag, for example
>
> Here, it can be "net:"
>
> [PATCH net-next] net: check net_enable_timestamp() is not called in i=
rq context
>
>>
>> Move warning on the top of function net_enable_timestamp,
>> so we would be also warn if we are going to use jump_label_dec in in=
terrupt
>>
>> Signed-off-by: Igor Maravic <igorm@etf.rs>
>>
>> :100644 100644 45eab03... d358088... M =C2=A0 =C2=A0 =C2=A0 =C2=A0ne=
t/core/dev.c
>>
>
> Missing "---" separator
>
> Please carefully read Documentation/SubmittingPatches
>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 45eab03..d358088 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1451,16 +1451,18 @@ static atomic_t netstamp_needed_deferred;
>>
>> =C2=A0void net_enable_timestamp(void)
>> =C2=A0{
>> + =C2=A0 =C2=A0 WARN_ON(in_interrupt());
>> =C2=A0#ifdef HAVE_JUMP_LABEL
>> - =C2=A0 =C2=A0 int deferred =3D atomic_xchg(&netstamp_needed_deferr=
ed, 0);
>> -
>> - =C2=A0 =C2=A0 if (deferred) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (--deferred)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 jump_label_dec(&netstamp_needed);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> + =C2=A0 =C2=A0 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int deferred =3D atomic_=
xchg(&netstamp_needed_deferred, 0);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (deferred) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 while (--deferred)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 jump_label_dec(&netstamp_needed);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0#endif
>> - =C2=A0 =C2=A0 WARN_ON(in_interrupt());
>> =C2=A0 =C2=A0 =C2=A0 jump_label_inc(&netstamp_needed);
>> =C2=A0}
>> =C2=A0EXPORT_SYMBOL(net_enable_timestamp);
>
>
>
