From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Wed, 4 Oct 2006 09:00:09 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610040859120.2679@d.namei>
References: <Pine.LNX.4.64.0610010203440.8658@d.namei> <20061002112050.GA772@2ka.mipt.ru>
 <Pine.LNX.4.64.0610020919050.9400@d.namei> <20061002134200.GA20441@2ka.mipt.ru>
 <Pine.LNX.4.64.0610021004180.9739@d.namei> <Pine.LNX.4.64.0610021020390.9909@d.namei>
 <20061002160021.GA8823@2ka.mipt.ru> <Pine.LNX.4.64.0610021208050.10965@d.namei>
 <20061002163013.GA24585@2ka.mipt.ru> <Pine.LNX.4.64.0610021238450.11172@d.namei>
 <20061004050839.GE32267@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:45758 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932407AbWJDNAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 09:00:12 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061004050839.GE32267@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2006, Evgeniy Polyakov wrote:

> Linux kano 2.6.18 #5 SMP Mon Oct 2 18:44:30 MSD 2006 i686 i686 i386 GNU/Linux
> [root@kano ~]# rpm -q selinux-policy-targeted
> selinux-policy-targeted-2.3.17-2
> 
> I get only this messages in audit.log when remote racoon tries to
> connect to system with selinux enabled in enforcing mode:
> 

I think the policy has just not been written for racoon, and it's being 
denied by deault (cd'd Dan Walsh).

> type=AVC msg=audit(1159938297.845:625): avc:  denied  { polmatch } for
> scontext=system_u:object_r:unlabeled_t:s0
> tcontext=root:system_r:unconfined_t:s0-s0:c0.c255 tclass=association
> type=AVC msg=audit(1159938297.845:626): avc:  denied  { polmatch } for
> scontext=system_u:object_r:unlabeled_t:s0
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> type=AVC msg=audit(1159938307.837:627): avc:  denied  { polmatch } for
> scontext=system_u:object_r:unlabeled_t:s0
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> type=AVC msg=audit(1159938317.838:628): avc:  denied  { polmatch } for
> scontext=system_u:object_r:unlabeled_t:s0
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> type=AVC msg=audit(1159938327.839:629): avc:  denied  { polmatch } for
> scontext=system_u:object_r:unlabeled_t:s0
> tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
> 
> It is with your patch applied.
> Should I try Venkat's or it is unrelated problem?
> 
> > -- 
> > James Morris
> > <jmorris@namei.org>
> 
> 

-- 
James Morris
<jmorris@namei.org>
