From: James Morris <jmorris@namei.org>
Subject: Re: updated [Patch 1/1] AF_UNIX Datagram getpeersec
Date: Sat, 17 Jun 2006 11:46:37 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606171145260.16900@d.namei>
References: <OF42C27083.DD6A539B-ON85257190.00252DFB-85257190.0025456C@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>, akpm@osdl.org,
	chrisw@osdl.org, Catherine Zhang <cxzhang@watson.ibm.com>,
	czhang.us@gmail.com, davem@davemloft.net,
	George Wilson <gcwilson@us.ibm.com>,
	herbert@gondor.apana.org.au, jmorris@redhat.com,
	latten@austin.ibm.com, netdev@vger.kernel.org, sds@tycho.nsa.gov,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:52900 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751666AbWFQPql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 11:46:41 -0400
To: Xiaolan Zhang <cxzhang@us.ibm.com>
In-Reply-To: <OF42C27083.DD6A539B-ON85257190.00252DFB-85257190.0025456C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 17 Jun 2006, Xiaolan Zhang wrote:

> Hi, Stephen,
> 
> It appears that selinux_enabled is defined inside selinux module and not 
> visible to the rest of the kernel...

Yes, these are SELinux API functions, they belong in 
security/selinux/exports.c

But what about Stephens question on the return value?


> 
> thanks,
> Catherine
> 
> Stephen Hemminger <shemminger@osdl.org> wrote on 06/17/2006 12:16:03 AM:
> 
> > O
> > > 
> > > +void selinux_get_sock_sid(const struct socket *sock, u32 *sid)
> > > +{
> > > +   if (selinux_enabled) {
> > > +      const struct inode *inode = SOCK_INODE(sock);
> > > +      selinux_get_inode_sid(inode, sid);
> > > +      return;
> > > +   }
> > > +   *sid = 0;
> > > +}
> > > +
> > 
> > This is so short, it would make sense to put it in scm.h
> > and why not have it return the value instead of call by reference?
> > Same goes for selinux_get_inode_sid
> > 
> > static inline void selinux_get_sock_sid(const struct socket *sock, u32 
> *sid)
> > {
> >    if (selinux_enabled)
> >       selinux_get_inode_sid(SOCK_INODE(sock), sid);
> >    else
> >       *sid = 0;
> > }
> > 
> > or
> > static inline u32 selinux_get_sock_sid(const struct socket *sock)
> > {
> >    return selinux_enabled ? selinux_get_inode_sid(SOCK_INODE(sid)) : 0;
> > }
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
