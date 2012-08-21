From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 19:44:27 +0200
Message-ID: <CAF6-1L61YcoqJAnoq=BrbFvdrk3=mE4jwP9RBByE80p1zbLFiA@mail.gmail.com>
References: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>
	<1345555336.5158.493.camel@edumazet-glaptop>
	<1345560131.5158.500.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50169 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab2HURo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 13:44:28 -0400
Received: by vbbff1 with SMTP id ff1so78947vbb.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 10:44:27 -0700 (PDT)
In-Reply-To: <1345560131.5158.500.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Following patch should help :
>
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 621e351..a04aa37 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -435,7 +435,7 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
>         if (expires == 0)
>                 expires = 1;
>
> -       if (dst->expires == 0 || time_before(expires, dst->expires))
> +       if (dst->expires == 0 || time_after(expires, dst->expires))
>                 dst->expires = expires;
>  }

Yes, this fixes it for me too . ( 2h without issues on 2 different machines )

But that line has been in the kernel for _years_ ... so I'm not sure
what's going on there ...


Cheers,

    Sylvain
