From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 9/9] net: add opaque struct around skb frag page
Date: Mon, 10 Oct 2011 16:13:56 +0100
Message-ID: <1318259636.21903.451.camel@zakaz.uk.xensource.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
	 <1318245101-16890-9-git-send-email-ian.campbell@citrix.com>
	 <1318259375.3227.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:43911 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737Ab1JJPN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 11:13:57 -0400
In-Reply-To: <1318259375.3227.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-10 at 16:09 +0100, Eric Dumazet wrote:
> Le lundi 10 octobre 2011 =C3=A0 12:11 +0100, Ian Campbell a =C3=A9cri=
t :
> > I've split this bit out of the skb frag destructor patch since it h=
elps enforce
> > the use of the fragment API.
> >=20
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > ---
> >  include/linux/skbuff.h |   10 ++++++----
> >  net/core/skbuff.c      |    6 +++---
> >  2 files changed, 9 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index ac6b05a..f881d75 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -135,7 +135,9 @@ struct sk_buff;
> >  typedef struct skb_frag_struct skb_frag_t;
> > =20
> >  struct skb_frag_struct {
> > -	struct page *page;
> > +	struct {
> > +		struct page *p;
> > +	} page;
>=20
> Oh well, why dont you rename page to something else, say frag_page ?

I looked at renaming this field and the impact was far larger than this
(already huge) set of series.

Keeping the name for the outer struct also has the nice property that
when the struct becomes something like:

	struct {
		struct page *p;
		struct skb_frag_destructor *destr;
	} page;

existing code which does
	fraga->page =3D fragb->page
will carry the destructor along magically without needing modification.

Ian.

>=20
>=20
>=20
