From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Mon, 29 Jun 2009 11:34:13 +0200
Message-ID: <20090629093413.GC3845@jolsa.lab.eng.brq.redhat.com>
References: <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com> <20090626145027.GA6534@redhat.com> <alpine.DEB.1.10.0906261111230.16400@makko.or.mcafeemobile.com> <20090626.111738.141246987.davem@davemloft.net> <4A452300.5080507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, davidel@xmailserver.org,
	oleg@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	htejun@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33010 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758638AbZF2JeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 05:34:15 -0400
Content-Disposition: inline
In-Reply-To: <4A452300.5080507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 09:35:28PM +0200, Eric Dumazet wrote:
> David Miller a =E9crit :
> > From: Davide Libenzi <davidel@xmailserver.org>
> > Date: Fri, 26 Jun 2009 11:12:15 -0700 (PDT)
> >=20
> >> On Fri, 26 Jun 2009, Oleg Nesterov wrote:
> >>
> >>> Perhaps we can add
> >>>
> >>> 	void sock_poll_wait(struct file *file, struct sock *sk, poll_tab=
le *pt)
> >>> 	{
> >>> 		if (pt) {
> >>> 			poll_wait(file, sk->sk_sleep, pt);
> >>> 			/*
> >>> 			 * fat comment
> >>> 			 */
> >>> 			smp_mb(); // or smp_mb__after_unlock();
> >>> 		}
> >>> 	}
> >> That'd be fine IMHO. Are DaveM and Eric OK?
> >=20
> > No objections from me.
>=20
> Very good :)
>=20
> Jiri, please respin a patch with this idea from Oleg
>=20
> (We'll have to check all calls to poll_wait() in net tree)
>=20
> Thanks everybody
>

thanks a lot! :) I'll send out new patch shortly..

I'll include all the poll_wait calls change I'm kind of sure of,
and list of others I'm not, so we can discuss them.

jirka
