From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH] iucv: properly clone LSM attributes to newly created
 child sockets
Date: Mon, 13 Jun 2016 16:38:01 +0200
Message-ID: <1465828681.4401.24.camel@BR9GV9YG.de.ibm.com>
References: <OFBFC201CF.D9C45214-ONC1257FCD.0059BB30-C1257FCD.0059C94A@notes.na.collabserv.com>
	 <1465812526.4401.4.camel@BR9GV9YG.de.ibm.com>
	 <CAHC9VhQPhSAudMSJ6j7cYYdZvYYwpyxMhT6yoGYeXm_oBThSaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <pmoore@redhat.com>, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34683 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933313AbcFMOiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 10:38:08 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5DEXl8W141429
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:38:08 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23gbjuwbbu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:38:07 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 15:38:06 +0100
In-Reply-To: <CAHC9VhQPhSAudMSJ6j7cYYdZvYYwpyxMhT6yoGYeXm_oBThSaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-13 at 08:38 -0400, Paul Moore wrote:
> On Mon, Jun 13, 2016 at 6:08 AM, Ursula Braun <ubraun@linux.vnet.ibm.com> wrote:
> >> From: Paul Moore <paul@paul-moore.com>
> >>
> >> Much like we had to do for AF_BLUETOOTH and AF_ALG, make sure we
> >> properly clone the parent socket's LSM attributes to newly created
> >> child sockets.
> >>
> >> Signed-off-by: Paul Moore <paul@paul-moore.com>
> >> ---
> >> net/iucv/af_iucv.c |    5 ++++-
> >> 1 file changed, 4 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
> >> index fc3598a..a0d1e36 100644
> >> --- a/net/iucv/af_iucv.c
> >> +++ b/net/iucv/af_iucv.c
> >> @@ -22,6 +22,7 @@
> >> #include <linux/skbuff.h>
> >> #include <linux/init.h>
> >> #include <linux/poll.h>
> >> +#include <linux/security.h>
> >> #include <net/sock.h>
> >> #include <asm/ebcdic.h>
> >> #include <asm/cpcmd.h>
> >> @@ -530,8 +531,10 @@ static void iucv_sock_close(struct sock *sk)
> >>
> >> static void iucv_sock_init(struct sock *sk, struct sock *parent)
> >> {
> >> -                 if (parent)
> >> +                 if (parent) {
> >>                                   sk->sk_type = parent->sk_type;
> >> +                                  security_sk_clone(parent, sk);
> >> +                 }
> >> }
> >>
> >> static struct sock *iucv_sock_alloc(struct socket *sock, int proto,
> >> gfp_t prio, int kern)
> >
> > applied locally - thx. Your patch will now be submitted for inclusion
> > into net-next.
> 
> Hi Ursula,
> 
> For what it's worth, I applied to the selinux#next branch last week,
> it should be in the linux-next builds.
> 
> * git://git.infradead.org/users/pcmoore/selinux
> * http://git.infradead.org/users/pcmoore/selinux
> 

ok, in this case I will not submit your patch myself.
