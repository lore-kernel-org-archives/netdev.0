From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Mon, 2 Oct 2006 12:41:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610021238450.11172@d.namei>
References: <20060930144018.GA16918@2ka.mipt.ru> <Pine.LNX.4.64.0609301044090.26813@d.namei>
 <Pine.LNX.4.64.0610010203440.8658@d.namei> <20061002112050.GA772@2ka.mipt.ru>
 <Pine.LNX.4.64.0610020919050.9400@d.namei> <20061002134200.GA20441@2ka.mipt.ru>
 <Pine.LNX.4.64.0610021004180.9739@d.namei> <Pine.LNX.4.64.0610021020390.9909@d.namei>
 <20061002160021.GA8823@2ka.mipt.ru> <Pine.LNX.4.64.0610021208050.10965@d.namei>
 <20061002163013.GA24585@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:52138 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965063AbWJBQl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 12:41:59 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061002163013.GA24585@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Oct 2006, Evgeniy Polyakov wrote:

> > Can you look in /var/log/audit/audit.log ? (especially grep for 
> > 'association' )
> 
> Indeed.
> 
> type=AVC msg=audit(1159804556.391:21): avc:  denied  { polmatch } for
> pid=2213 comm="racoon" scontext=root:system_r:unconfined_t:s0-s0:c0.c255
> tcontext=root:system_r:unconfined_t:s0-s0:c0.c255 tclass=association

Ok, that's it.

> But then it is quite strange why FC5 2.6.17-1.2187_FC5smp works,
> are there some bindings to the kernel version?
> (my knowledge about selinux changes related to xfrm are somewhere
> between zero and void).

The SELinux policy is loosely bound to the kernel version.  Generally, if 
you run development kernels, you need development SELinux policy.

> > What version of SELinux policy are you using?
> > 
> > i.e. $ rpm -q selinux-policy-targeted
> 
> selinux-policy-targeted-2.3.7-2.fc5

Yep, that's ancient.

> I run it every day in cron and there are no updates at
> 
> http://download.fedora.redhat.com/pub/fedora/linux/core/updates/5/i386/
> 
> behind my version.

You can get recent policy packages via the devel repo, which I'd suggest 
if you're using development (or DIY) kernels.



-- 
James Morris
<jmorris@namei.org>
