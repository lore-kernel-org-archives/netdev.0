From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/8] net: add limit for socket backlog
Date: Wed, 03 Mar 2010 09:02:37 +0100
Message-ID: <1267603357.2839.105.camel@edumazet-laptop>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267599269.2839.84.camel@edumazet-laptop>
	 <1267601728.2370.47.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:59253 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185Ab0CCICp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:02:45 -0500
Received: by bwz1 with SMTP id 1so444070bwz.1
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 00:02:43 -0800 (PST)
In-Reply-To: <1267601728.2370.47.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 15:35 +0800, Zhu Yi a =C3=A9crit :
> On Wed, 2010-03-03 at 14:54 +0800, Eric Dumazet wrote:
> > > diff --git a/include/net/sock.h b/include/net/sock.h
> > > index 6cb1676..847119a 100644
> > > --- a/include/net/sock.h
> > > +++ b/include/net/sock.h
> > > @@ -253,6 +253,8 @@ struct sock {
> > >  	struct {
> > >  		struct sk_buff *head;
> > >  		struct sk_buff *tail;
> > > +		int len;
> > > +		int limit;
> >=20
> > This new limit field is really not needed
>=20
> sk->sk_rcvbuf can be adjusted by setsockopt from user at run time. Th=
e
> minimum allowed value is 256. I'm afraid this will break most protoco=
ls.

I see, then maybe use some offset in your test, to allow some extra
space.

#define MINBACKLOG 2048

if (sk->sk_backlog.len >=3D (sk->sk_rcvbuf << 1) + MINBACKLOG)
	return -ENOBUFS;



