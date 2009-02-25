From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 23/26] RDS: Add AF and PF #defines for RDS sockets
Date: Wed, 25 Feb 2009 13:36:36 +0200
Message-ID: <200902251336.36461.remi.denis-courmont@nokia.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com> <1235525443-9007-24-git-send-email-andy.grover@oracle.com> <20090224.232648.84203571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "andy.grover@oracle.com" <andy.grover@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:56566 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbZBYLgw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 06:36:52 -0500
In-Reply-To: <20090224.232648.84203571.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 25 February 2009 09:26:48 ext David Miller, you wrote:
> From: Andy Grover <andy.grover@oracle.com>
> Date: Tue, 24 Feb 2009 17:30:40 -0800
>
> > @@ -191,7 +191,8 @@ struct ucred {
> >  #define AF_RXRPC     33      /* RxRPC sockets                */
> >  #define AF_ISDN              34      /* mISDN sockets             =
   */
> >  #define AF_PHONET    35      /* Phonet sockets               */
> > -#define AF_MAX               36      /* For now.. */
> > +#define AF_RDS               36      /* RDS sockets               =
   */
> > +#define AF_MAX               37      /* For now.. */
> >
> >  /* Protocol families, same as address families. */
> >  #define PF_UNSPEC    AF_UNSPEC
>
> Pick an unused number, you don't have to increment AF_MAX
> to allocate a value.

But that patch is also allocating a PF value and net/socket.c has:
        if (ops->family >=3D NPROTO) {
                printk(KERN_CRIT "protocol %d >=3D NPROTO(%d)\n", ops->=
family,
                       NPROTO);
                return -ENOBUFS;
        }

=2E..while include/linux/net.h has:
#define NPROTO              AF_MAX

Also, the lock dependency checks can cope with AF_MAX, but not AF_MAX+1=
=2E I=20
have gone through that myself... I can testify it's annoying when the l=
atest=20
socket family of the kernel version of the day failed to declare its lo=
ck=20
classes. Then that family "works" but the one you're trying triggers ob=
noxious=20
locking warnings that are not your own fault.

> And I don't want to hear any whining about how you've
> used this value of 36 internally for a long time or
> anything like that.

So I guess you don't want to hear how AF_PHONET overloaded AF_ECONET be=
fore we=20
published it :) But anyway, Econet had those cool properties that we di=
d not=20
use it, and that it had a private pointer in net_device (although Phone=
t does=20
not need a private device pointer anymore) :P

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

