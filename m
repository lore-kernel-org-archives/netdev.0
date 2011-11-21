From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [patch] fix error handle in ip_mc_add_src()
Date: Mon, 21 Nov 2011 07:37:54 -0800
Message-ID: <OFBC156DC4.826FDC8E-ON8825794F.0055A924-8825794F.0055DE4A@us.ibm.com>
References: <1321887946.14281.27.camel@barry.pixelworks.com>	 <1321889066.10470.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1321889410.14281.31.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:47054 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802Ab1KUPqn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 10:46:43 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 21 Nov 2011 08:46:41 -0700
In-Reply-To: <1321889410.14281.31.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With Eric's changes,

Acked-by: David L Stevens <dlstevens@us.ibm.com>

Good catch!

					+-DLS

netdev-owner@vger.kernel.org wrote on 11/21/2011 07:30:10 AM:

> From: Jun Zhao <mypopydev@gmail.com>
> To: Eric Dumazet <eric.dumazet@gmail.com>,
> Cc: davem@davemloft.net, netdev@vger.kernel.org
> Date: 11/21/2011 07:32 AM
> Subject: Re: [patch] fix error handle in ip_mc_add_src()
> Sent by: netdev-owner@vger.kernel.org
>
> On Mon, 2011-11-21 at 16:24 +0100, Eric Dumazet wrote:
> > Le lundi 21 novembre 2011 =E0 23:05 +0800, Jun Zhao a =E9crit :
> > > When add sources to interface failure, need to roll back the
> sfcount[MODE]
> > > to before state. We need to match it corresponding.
> > >
> >
> > Missing "---" separator
> >
> > > diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> > > index c7472ef..276719a 100644
> > > --- a/net/ipv4/igmp.c
> > > +++ b/net/ipv4/igmp.c
> > > @@ -1716,7 +1716,8 @@ static int ip_mc_add_src(struct in_device
> *in_dev, __be32 *pmca, int sfmode,
> > >     if (err) {
> > >        int j;
> > >
> > > -      pmc->sfcount[sfmode]--;
> > > +      if(!delta)
> >
> > Missing space, should be  : if (!delta)
> >
> > > +         pmc->sfcount[sfmode]--;
> > >        for (j=3D0; j<i; j++)
> > >           (void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
> > >     } else if (isexclude !=3D (pmc->sfcount[MCAST_EXCLUDE] !=3D 0=
)) {
> > >
> > > Signed-off-by: Jun Zhao <mypopydev@gmail.com>
> > >
> >
> > Your "Signed-off-by:" should come before actual patch
> >
> > Please read Documentation/SubmittingPatches
> >
> > Thanks
> >
> >
> >
>
> Tks, Eric Dumazet , I will re-submit this patch and follow the format=
=2E
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
