From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/3] tcp: Slightly optimize tcp_sendmsg
Date: Thu, 10 Dec 2009 15:59:45 +0530
Message-ID: <OFC615F4FC.74D9EC7D-ON65257688.003074DE-65257688.0038A471@in.ibm.com>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain> <20091209082624.19055.99645.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0912101016040.23376@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:43268 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933517AbZLJKSj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:18:39 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBAAIiFY021226
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 15:48:44 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBAAIi6u3665950
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 15:48:44 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBAAIhAj012126
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 15:48:44 +0530
In-Reply-To: <alpine.DEB.2.00.0912101016040.23376@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,

"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote on 12/10/2009 01:47=
:30
PM:

> Subject: Re: [PATCH 3/3] tcp: Slightly optimize tcp_sendmsg>
>
> > Slightly optimize tcp_sendmsg since NETIF_F_SG is used many
> > times iteratively in the loop. The only other modification is
> > to change:
> >          } else if (i =3D=3D MAX_SKB_FRAGS ||
> >                (!i &&
> >                !(sk->sk_route_caps & NETIF_F_SG))) {
> >    to:
> >          } else if (i =3D=3D MAX_SKB_FRAGS || !sg) {
>
> I can see that you make this change from the patch itself but could y=
ou
> give a justification on why dropping the !i is possible? ...I couldn'=
t
> see what would allow that.

=46rom what *I understood*, this code (other than the MAX_SKB_FRAGS cas=
e)
executes only due to the else part of "if (skb_tailroom(skb) > 0) {" -
there was no space in the skb to put the data inline. Hence SG is false
is a sufficient condition and there is no way to add a fragment (i =3D=3D=
 0
since skb_fill_page_desc cannot be called when !SG).

thanks,

- KK

