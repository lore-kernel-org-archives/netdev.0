From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: updated [Patch 1/1] AF_UNIX Datagram getpeersec
Date: Sat, 17 Jun 2006 02:47:04 -0400
Message-ID: <OF42C27083.DD6A539B-ON85257190.00252DFB-85257190.0025456C@us.ibm.com>
References: <20060616211603.14547a1d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: akpm@osdl.org, chrisw@osdl.org,
	Catherine Zhang <cxzhang@watson.ibm.com>, czhang.us@gmail.com,
	davem@davemloft.net, George Wilson <gcwilson@us.ibm.com>,
	herbert@gondor.apana.org.au, jmorris@redhat.com,
	latten@austin.ibm.com, netdev@vger.kernel.org, sds@tycho.nsa.gov,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:43649 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932405AbWFQGrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2006 02:47:11 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5H6l7c0021803
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 17 Jun 2006 02:47:08 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5H6l7C1187196
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 17 Jun 2006 02:47:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5H6l6Mm025184
	for <netdev@vger.kernel.org>; Sat, 17 Jun 2006 02:47:07 -0400
In-Reply-To: <20060616211603.14547a1d@localhost.localdomain>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Stephen,

It appears that selinux_enabled is defined inside selinux module and not 
visible to the rest of the kernel...

thanks,
Catherine

Stephen Hemminger <shemminger@osdl.org> wrote on 06/17/2006 12:16:03 AM:

> O
> > 
> > +void selinux_get_sock_sid(const struct socket *sock, u32 *sid)
> > +{
> > +   if (selinux_enabled) {
> > +      const struct inode *inode = SOCK_INODE(sock);
> > +      selinux_get_inode_sid(inode, sid);
> > +      return;
> > +   }
> > +   *sid = 0;
> > +}
> > +
> 
> This is so short, it would make sense to put it in scm.h
> and why not have it return the value instead of call by reference?
> Same goes for selinux_get_inode_sid
> 
> static inline void selinux_get_sock_sid(const struct socket *sock, u32 
*sid)
> {
>    if (selinux_enabled)
>       selinux_get_inode_sid(SOCK_INODE(sock), sid);
>    else
>       *sid = 0;
> }
> 
> or
> static inline u32 selinux_get_sock_sid(const struct socket *sock)
> {
>    return selinux_enabled ? selinux_get_inode_sid(SOCK_INODE(sid)) : 0;
> }

