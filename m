From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 3/3] team: replicate options on register
Date: Thu, 17 Nov 2011 11:00:23 +0100
Message-ID: <1321524023.2751.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
	 <1321477749-1877-4-git-send-email-jpirko@redhat.com>
	 <1321518736.3274.45.camel@edumazet-laptop>
	 <20111117095729.GA2093@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37447 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240Ab1KQKA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 05:00:28 -0500
Received: by bke11 with SMTP id 11so1754704bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 02:00:26 -0800 (PST)
In-Reply-To: <20111117095729.GA2093@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 10:57 +0100, Jiri Pirko a =C3=A9crit :
> Thu, Nov 17, 2011 at 09:32:16AM CET, eric.dumazet@gmail.com wrote:
> >Le mercredi 16 novembre 2011 =C3=A0 22:09 +0100, Jiri Pirko a =C3=A9=
crit :
> >
> >> +
> >> +int team_options_register(struct team *team,
> >> +			  const struct team_option *option,
> >> +			  size_t option_count)
> >>  {
> >>  	int i;
> >> +	struct team_option *dst_opts[option_count];
> >> +	int err;
> >
> >This kind of construct will trigger static analyzer alerts...
>=20
>=20
> I thought this is ok to do in kernel. Should I replace that with
> kmalloc/kfree?

If you know the absolute limit of option_count, you could use

struct team_option *dst_opts[OPTION_COUNT_MAX];

If not, then a kmalloc()/kfree() is probably needed ;)
