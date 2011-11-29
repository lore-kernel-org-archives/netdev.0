From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH] Fix jump_label handling in dev.c
Date: Tue, 29 Nov 2011 12:07:43 +0100
Message-ID: <CAFdo_mWQzLQpgN0NjzXJ9HoeKCbzF9TLfC4-RZwp_=DFY25Gsg@mail.gmail.com>
References: <igorm@etf.rs>
	<1322562649-20876-1-git-send-email-igorm@etf.rs>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:45342 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753107Ab1K2LHw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 06:07:52 -0500
Received: from localhost (avs2.etf.rs [147.91.14.173])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 7FBCE6012E
	for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 12:07:51 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs2.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id gJalxMwm-+xj for <netdev@vger.kernel.org>;
	Tue, 29 Nov 2011 12:07:46 +0100 (CET)
Received: from mail-yw0-f46.google.com (mail-yw0-f46.google.com [209.85.213.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id E369112011F
	for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 12:07:45 +0100 (CET)
Received: by ywa9 with SMTP id 9so3948511ywa.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 03:07:44 -0800 (PST)
In-Reply-To: <1322562649-20876-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore this.
My mistake.

2011/11/29  <igorm@etf.rs>:
> From: Igor Maravic <igorm@etf.rs>
>
> static_branch instead of atomic_read.
> Eric forgot to replace that.
>
> Signed-off-by: Igor Maravic <igorm@etf.rs>
>
> :100644 100644 579ce33... d358088... M =A0net/core/dev.c
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 579ce33..d358088 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1482,12 +1482,12 @@ EXPORT_SYMBOL(net_disable_timestamp);
> =A0static inline void net_timestamp_set(struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0skb->tstamp.tv64 =3D 0;
> - =A0 =A0 =A0 if (atomic_read(&netstamp_needed))
> + =A0 =A0 =A0 if (static_branch(&netstamp_needed))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__net_timestamp(skb);
> =A0}
>
> =A0#define net_timestamp_check(COND, SKB) =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 \
> - =A0 =A0 =A0 if (atomic_read(&netstamp_needed)) { =A0 =A0 =A0 =A0 =A0=
 =A0\
> + =A0 =A0 =A0 if (static_branch(&netstamp_needed)) { =A0 =A0 =A0 =A0 =
=A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((COND) && !(SKB)->tstamp.tv64) =A0=
 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__net_timestamp(SKB); =
=A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> --
> 1.7.5.4
>
>
