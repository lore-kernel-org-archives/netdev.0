From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Wed, 4 Oct 2006 09:08:39 +0400
Message-ID: <20061004050839.GE32267@2ka.mipt.ru>
References: <Pine.LNX.4.64.0610010203440.8658@d.namei> <20061002112050.GA772@2ka.mipt.ru> <Pine.LNX.4.64.0610020919050.9400@d.namei> <20061002134200.GA20441@2ka.mipt.ru> <Pine.LNX.4.64.0610021004180.9739@d.namei> <Pine.LNX.4.64.0610021020390.9909@d.namei> <20061002160021.GA8823@2ka.mipt.ru> <Pine.LNX.4.64.0610021208050.10965@d.namei> <20061002163013.GA24585@2ka.mipt.ru> <Pine.LNX.4.64.0610021238450.11172@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48617 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030293AbWJDFP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 01:15:57 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610021238450.11172@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 12:41:57PM -0400, James Morris (jmorris@namei.org) wrote:
> You can get recent policy packages via the devel repo, which I'd suggest 
> if you're using development (or DIY) kernels.

[root@kano ~]# uname -a
Linux kano 2.6.18 #5 SMP Mon Oct 2 18:44:30 MSD 2006 i686 i686 i386 GNU/Linux
[root@kano ~]# rpm -q selinux-policy-targeted
selinux-policy-targeted-2.3.17-2

I get only this messages in audit.log when remote racoon tries to
connect to system with selinux enabled in enforcing mode:

type=AVC msg=audit(1159938297.845:625): avc:  denied  { polmatch } for
scontext=system_u:object_r:unlabeled_t:s0
tcontext=root:system_r:unconfined_t:s0-s0:c0.c255 tclass=association
type=AVC msg=audit(1159938297.845:626): avc:  denied  { polmatch } for
scontext=system_u:object_r:unlabeled_t:s0
tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
type=AVC msg=audit(1159938307.837:627): avc:  denied  { polmatch } for
scontext=system_u:object_r:unlabeled_t:s0
tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
type=AVC msg=audit(1159938317.838:628): avc:  denied  { polmatch } for
scontext=system_u:object_r:unlabeled_t:s0
tcontext=system_u:object_r:unlabeled_t:s0 tclass=association
type=AVC msg=audit(1159938327.839:629): avc:  denied  { polmatch } for
scontext=system_u:object_r:unlabeled_t:s0
tcontext=system_u:object_r:unlabeled_t:s0 tclass=association

It is with your patch applied.
Should I try Venkat's or it is unrelated problem?

> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
