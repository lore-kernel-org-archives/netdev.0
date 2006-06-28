From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (with latest updates)
Date: Tue, 27 Jun 2006 21:52:40 -0400
Message-ID: <OF5E332833.A2E43B52-ON8525719B.0009D441-8525719B.000A510A@us.ibm.com>
References: <Pine.LNX.4.64.0606272130080.6477@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@osdl.org>, chrisw@osdl.org,
	Catherine Zhang <cxzhang@watson.ibm.com>, czhang.us@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	George Wilson <gcwilson@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	latten@austin.ibm.com, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Serge E Hallyn <sergeh@us.ibm.com>, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:10881 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932688AbWF1Bwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 21:52:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5S1qiSV019165
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 21:52:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5S1qhp0269444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 21:52:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5S1qgJE016876
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 21:52:43 -0400
In-Reply-To: <Pine.LNX.4.64.0606272130080.6477@d.namei>
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris <jmorris@namei.org> wrote on 06/27/2006 09:33:17 PM:

> On Tue, 27 Jun 2006, Catherine Zhang wrote:
> 
> > diff -puN security/selinux/exports.c~lsm-secpeer-unix 
> security/selinux/exports.c
> > --- linux-2.6.17-rc6-mm2-JM/security/selinux/exports.c~lsm-
> secpeer-unix   2006-06-27 18:15:10.914669944 -0400
> > +++ linux-2.6.17-rc6-mm2-JM-cxzhang/security/selinux/exports.c 
> 2006-06-27 18:16:31.502418744 -0400
> > @@ -17,6 +17,7 @@
> >  #include <linux/selinux.h>
> >  #include <linux/fs.h>
> >  #include <linux/ipc.h>
> > +#include <net/sock.h>
> > 
> >  #include "security.h"
> >  #include "objsec.h"
> > @@ -72,6 +73,16 @@ void selinux_get_task_sid(struct task_st
> >     *sid = 0;
> >  }
> > 
> > +void selinux_get_sock_sid(struct socket *sock, u32 *sid)
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
> 
> Just one more thing, we don't need to export this function now.

You mean moving it to security/selinux/hooks.c and making it static?

I think conceptually this is where it should reside -- auditing system 
might need it in the future, for example.

thanks,
Catherine


