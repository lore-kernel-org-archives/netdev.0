From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH 1/3] Phonet: Netlink factorization and cleanup
Date: Wed, 24 Sep 2008 19:44:56 +0300
Message-ID: <200809241944.58386.rdenis@simphalempin.com>
References: <1222272700-28232-1-git-send-email-remi.denis-courmont@nokia.com> <20080924162507.GA13760@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39485 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424AbYIXQpA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 12:45:00 -0400
In-Reply-To: <20080924162507.GA13760@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 septembre 2008 19:25:07 Arnaldo Carvalho de Melo, vous a=
vez =E9crit=A0:
> Em Wed, Sep 24, 2008 at 07:11:38PM +0300, Remi Denis-Courmont escreve=
u:
> > From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> >
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
> > ---
> >  net/phonet/pn_netlink.c |   91
> > ++++++++++++++++++----------------------------- 1 files changed, 35
> > insertions(+), 56 deletions(-)
> >
> > diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
> > index b1ea19a..b1770d6 100644
> > --- a/net/phonet/pn_netlink.c
> > +++ b/net/phonet/pn_netlink.c
> > @@ -54,11 +54,16 @@ errout:
> >  		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_IFADDR, err);
> >  }
> >
> > -static int newaddr_doit(struct sk_buff *skb, struct nlmsghdr *nlm,=
 void
> > *attr) +static const struct nla_policy ifa_phonet_policy[IFA_MAX+1]=
 =3D {
>
> since you are changing the above line, please use [IFA_MAX + 1] for
> consistency

=46ine with me. But but... does that mean I should patch these too?

% grep -re 'IFA_MAX *+' net/
net/decnet/dn_dev.c:static const struct nla_policy dn_ifa_policy[IFA_MA=
X+1] =3D {
net/decnet/dn_dev.c:    struct nlattr *tb[IFA_MAX+1];
net/decnet/dn_dev.c:    struct nlattr *tb[IFA_MAX+1];
net/ipv6/addrconf.c:static const struct nla_policy ifa_ipv6_policy[IFA_=
MAX+1] =3D {
net/ipv6/addrconf.c:    struct nlattr *tb[IFA_MAX+1];
net/ipv6/addrconf.c:    struct nlattr *tb[IFA_MAX+1];
net/ipv6/addrconf.c:    struct nlattr *tb[IFA_MAX+1];
net/ipv4/devinet.c:static const struct nla_policy ifa_ipv4_policy[IFA_M=
AX+1] =3D {
net/ipv4/devinet.c:     struct nlattr *tb[IFA_MAX+1];
net/ipv4/devinet.c:     struct nlattr *tb[IFA_MAX+1];

(I wish I had to learn how to add it to checkpatch, as with && at EOL)

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
