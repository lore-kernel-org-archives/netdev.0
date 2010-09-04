From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UNIX: Do not loop forever at unix_autobind().
Date: Sat, 04 Sep 2010 12:55:29 +0200
Message-ID: <1283597729.3402.16.camel@edumazet-laptop>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
	 <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
	 <201008302227.DJH30258.OQFMFtFJOOVSHL@I-love.SAKURA.ne.jp>
	 <1283370450.2484.19.camel@edumazet-laptop>
	 <201009040658.o846wxnU028775@www262.sakura.ne.jp>
	 <1283584269.3402.9.camel@edumazet-laptop>
	 <201009040740.o847eB4f040772@www262.sakura.ne.jp>
	 <1283588647.3402.12.camel@edumazet-laptop>
	 <201009040931.o849VstI061086@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53090 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790Ab0IDKze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 06:55:34 -0400
Received: by fxm13 with SMTP id 13so1744079fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 03:55:33 -0700 (PDT)
In-Reply-To: <201009040931.o849VstI061086@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 septembre 2010 =C3=A0 18:31 +0900, Tetsuo Handa a =C3=A9cr=
it :
> +		cond_resched();
> +		/* Give up if all names seems to be in use. */
> +		if (retries++ =3D=3D 0xFFFFF) {
> +			err =3D -ENOMEM;
> +			kfree(addr);
> +			goto out;
> +		}
>  		goto retry;
>  	}
>  	addr->hash ^=3D sk->sk_type;

Yes, but please use a different error code, its not ENOMEM...
maybe EBUSY or ENOSPC ...



