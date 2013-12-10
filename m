From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: No netlink notification for user-initiated NUD state change
Date: Tue, 10 Dec 2013 18:15:48 +0100
Message-ID: <52A74C44.9060600@6wind.com>
References: <529558B7.5000506@aristanetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Bob Gilligan <gilligan@aristanetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:64189 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805Ab3LJRPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 12:15:53 -0500
Received: by mail-we0-f176.google.com with SMTP id w62so5335274wes.35
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 09:15:52 -0800 (PST)
In-Reply-To: <529558B7.5000506@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/11/2013 03:28, Bob Gilligan a =E9crit :
> Hi -- The neighbour code sends up an RTM_NEWNEIGH netlink notificatio=
n
> if the NUD state of a neighbour cache entry is changed by a timer (e.=
g.
> from REACHABLE to STALE), even if the lladdr of the entry has not cha=
nged.
>
> But a user-initiated change to the the NUD state of a neighbour cache
> entry that does not change the lladdr (e.g. via "ip -4 neigh change .=
=2E.
> nud ...") does not trigger a netlink notification.
>
> I'm wondering if that is intended behavior?  Is there any reason not =
to
> send a netlink notification in this case?  The situation we've seen
> where it would be nice to have these notifications is if a user chang=
es
> an existing resolved entry to PERMANENT.
>
> This one-line change to neigh_update() would trigger netlink
> notifications on all user-initiated state changes:
>
> Index: linux-3.12.1/net/core/neighbour.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-3.12.1.orig/net/core/neighbour.c
> +++ linux-3.12.1/net/core/neighbour.c
> @@ -1161,6 +1161,7 @@ int neigh_update(struct neighbour *neigh
>
> neigh->parms->reachable_time :
>                                                   0)));
>                  neigh->nud_state =3D new;
> +               notify =3D 1;
>          }
>
>          if (lladdr !=3D neigh->ha) {
>
>
>
> I'd be happy to submit a properly formatted patch if there's agreemen=
t
> that this is an issue.
I think this patch is good, please could you submit it properly?
