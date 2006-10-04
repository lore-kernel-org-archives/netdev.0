From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Wed, 4 Oct 2006 10:02:15 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF842@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:51241 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S964862AbWJDOCZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 10:02:25 -0400
To: James Morris <jmorris@namei.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evegeniy,

Please start with my patch which should actually address the issue
you were originally running into. I doubt that you were running into
the kind of errors that James' patch (which will need to be modified
to not treat -EACCES as an error to be propagated up the chain) would
handle.

Thanks,

venkat

> -----Original Message-----
> From: James Morris [mailto:jmorris@namei.org]
> Sent: Wednesday, October 04, 2006 8:00 AM
> To: Evgeniy Polyakov
> Cc: David S. Miller; Herbert Xu; netdev@vger.kernel.org; Stephen
> Smalley; Venkat Yekkirala; Paul Moore; Daniel J Walsh
> Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
> 
> 
> On Wed, 4 Oct 2006, Evgeniy Polyakov wrote:
> 
> > Linux kano 2.6.18 #5 SMP Mon Oct 2 18:44:30 MSD 2006 i686 
> i686 i386 GNU/Linux
> > [root@kano ~]# rpm -q selinux-policy-targeted
> > selinux-policy-targeted-2.3.17-2
> > 
> > I get only this messages in audit.log when remote racoon tries to
> > connect to system with selinux enabled in enforcing mode:
> > 
> 
> I think the policy has just not been written for racoon, and 
> it's being 
> denied by deault (cd'd Dan Walsh).
> 
> > type=AVC msg=audit(1159938297.845:625): avc:  denied  { 
> polmatch } for
> > scontext=system_u:object_r:unlabeled_t:s0
> > tcontext=root:system_r:unconfined_t:s0-s0:c0.c255 tclass=association
> > type=AVC msg=audit(1159938297.845:626): avc:  denied  { 
> polmatch } for
> > scontext=system_u:object_r:unlabeled_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> > type=AVC msg=audit(1159938307.837:627): avc:  denied  { 
> polmatch } for
> > scontext=system_u:object_r:unlabeled_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> > type=AVC msg=audit(1159938317.838:628): avc:  denied  { 
> polmatch } for
> > scontext=system_u:object_r:unlabeled_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> > type=AVC msg=audit(1159938327.839:629): avc:  denied  { 
> polmatch } for
> > scontext=system_u:object_r:unlabeled_t:s0
> > tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> > 
> > It is with your patch applied.
> > Should I try Venkat's or it is unrelated problem?
> > 
> > > -- 
> > > James Morris
> > > <jmorris@namei.org>
> > 
> > 
> 
> -- 
> James Morris
> <jmorris@namei.org>
> 
