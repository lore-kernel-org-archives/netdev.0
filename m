From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Tue, 29 Nov 2011 11:27:30 +0100
Message-ID: <1322562450.2285.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <igorm@etf.rs> <1322511796-6908-1-git-send-email-igorm@etf.rs>
	 <1322511796-6908-2-git-send-email-igorm@etf.rs>
	 <1322512426.2970.15.camel@edumazet-laptop>
	 <1322515010.2970.24.camel@edumazet-laptop>
	 <fba9911084786bf04747c0350e774615.squirrel@kondor.etf.bg.ac.rs>
	 <1322559093.2970.102.camel@edumazet-laptop>
	 <88caa73892721f74b81e72c1ff1a0be3.squirrel@kondor.etf.bg.ac.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59137 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474Ab1K2K1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 05:27:36 -0500
Received: by vbbfc26 with SMTP id fc26so4582756vbb.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 02:27:35 -0800 (PST)
In-Reply-To: <88caa73892721f74b81e72c1ff1a0be3.squirrel@kondor.etf.bg.ac.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 10:48 +0100, "Igor Maravi=C4=87" a =C3=
=A9crit :

>=20
> PS. Tested the patch - it works.
>=20
> [PATCH 1/1] Warning if_interrupt is true

=46ew remarks, since you start to send official patches ;)

- Since its not a serie of several patches, you dont need the 1/1
- Since tree is net-next, not net, you should say it to David
- We need a better title, with subsystem: tag, for example

Here, it can be "net:"

[PATCH net-next] net: check net_enable_timestamp() is not called in irq=
 context

>=20
> Move warning on the top of function net_enable_timestamp,
> so we would be also warn if we are going to use jump_label_dec in int=
errupt
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
>=20
> :100644 100644 45eab03... d358088... M	net/core/dev.c
>=20

Missing "---" separator

Please carefully read Documentation/SubmittingPatches

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 45eab03..d358088 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1451,16 +1451,18 @@ static atomic_t netstamp_needed_deferred;
>=20
>  void net_enable_timestamp(void)
>  {
> +	WARN_ON(in_interrupt());
>  #ifdef HAVE_JUMP_LABEL
> -	int deferred =3D atomic_xchg(&netstamp_needed_deferred, 0);
> -
> -	if (deferred) {
> -		while (--deferred)
> -			jump_label_dec(&netstamp_needed);
> -		return;
> +	{
> +		int deferred =3D atomic_xchg(&netstamp_needed_deferred, 0);
> +
> +		if (deferred) {
> +			while (--deferred)
> +				jump_label_dec(&netstamp_needed);
> +			return;
> +		}
>  	}
>  #endif
> -	WARN_ON(in_interrupt());
>  	jump_label_inc(&netstamp_needed);
>  }
>  EXPORT_SYMBOL(net_enable_timestamp);
