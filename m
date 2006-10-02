From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Mon, 2 Oct 2006 12:13:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610021208050.10965@d.namei>
References: <20060930111521.GA646@2ka.mipt.ru> <Pine.LNX.4.64.0609301035020.26766@d.namei>
 <20060930144018.GA16918@2ka.mipt.ru> <Pine.LNX.4.64.0609301044090.26813@d.namei>
 <Pine.LNX.4.64.0610010203440.8658@d.namei> <20061002112050.GA772@2ka.mipt.ru>
 <Pine.LNX.4.64.0610020919050.9400@d.namei> <20061002134200.GA20441@2ka.mipt.ru>
 <Pine.LNX.4.64.0610021004180.9739@d.namei> <Pine.LNX.4.64.0610021020390.9909@d.namei>
 <20061002160021.GA8823@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:24553 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965062AbWJBQNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 12:13:49 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061002160021.GA8823@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Oct 2006, Evgeniy Polyakov wrote:

> On Mon, Oct 02, 2006 at 10:27:13AM -0400, James Morris (jmorris@namei.org) wrote:
> > Updated version of the patch, which return directly after a flow cache 
> > lookup error in xfrm_lookup rather than returing via the cleanup path 
> > (which was causing a spurious dst_release).
> > 
> > This works for me, although I never saw the oops with the old patch.
> > 
> > Evgeniy, let me know if this fixes the oops you're seeing.
> 
> With enabled selinux in enforcing mode I can not even get messages to
> racoon, i.e. tcpdump sees first message of the daemon, but racoon log
> (with a lot of -d) is not changed.
> With permissive mode everything works fine.

I think this could be your security policy denying access (which is a 
strong suspicion, becuase you hit the problem easily and it requires a 
policy denial).

Can you look in /var/log/audit/audit.log ? (especially grep for 
'association' )

What version of SELinux policy are you using?

i.e. $ rpm -q selinux-policy-targeted

If it's not very recent, like 2.3.16-9 or better, you may need to run a 
yum update.


- James
-- 
James Morris
<jmorris@namei.org>

