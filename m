From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Tue, 21 Sep 2010 23:47:04 +0200
Message-ID: <1285105624.6378.24.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1009211154150.32565@pokey.mtv.corp.google.com>
	 <1285105131.6378.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39897 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432Ab0IUVrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:47:10 -0400
Received: by fxm3 with SMTP id 3so1809994fxm.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 14:47:08 -0700 (PDT)
In-Reply-To: <1285105131.6378.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 23:39 +0200, Eric Dumazet a =C3=A9cri=
t :

> > + * Copy the first unacked seq into the receive msg control part.
> > + */
> > +static inline void tcp_sock_xmit_compl_seq(struct msghdr *msg,
> > +					   struct sock *sk)
> > +{
> > +	if (sock_flag(sk, SOCK_XMIT_COMPL_SEQ)) {
> > +		struct tcp_sock *tp =3D tcp_sk(sk);
> > +		if (msg->msg_controllen >=3D sizeof(tp->snd_una)) {
=09
and this check is not necessary or correct ?

to put_cmsg() an u32, you need CMSG_LEN(4) bytes

> > +			put_cmsg(msg, SOL_SOCKET, SCM_XMIT_COMPL_SEQ,
> > +			    sizeof(tp->snd_una), &tp->snd_una);
> > +		}
> > +	}
> > +}

->

 if (sock_flag(sk, SOCK_XMIT_COMPL_SEQ))
	put_cmsg(msg, SOL_SOCKET, SCM_XMIT_COMPL_SEQ,
		 sizeof(u32), &snd_una);



