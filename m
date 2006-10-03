From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Tue, 03 Oct 2006 16:18:07 -0700 (PDT)
Message-ID: <20061003.161807.18306641.davem@davemloft.net>
References: <20061002134200.GA20441@2ka.mipt.ru>
	<Pine.LNX.4.64.0610021004180.9739@d.namei>
	<Pine.LNX.4.64.0610021020390.9909@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, sds@tycho.nsa.gov,
	vyekkirala@TrustedCS.com, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17321
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030673AbWJCXSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 19:18:06 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0610021020390.9909@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 2 Oct 2006 10:27:13 -0400 (EDT)

> Updated version of the patch, which return directly after a flow cache 
> lookup error in xfrm_lookup rather than returing via the cleanup path 
> (which was causing a spurious dst_release).
> 
> This works for me, although I never saw the oops with the old patch.
> 
> Evgeniy, let me know if this fixes the oops you're seeing.
> 
> Signed-off-by: James Morris <jmorris@namei.org>

As I review this patch I realize there is a question of
semantics and prioritization here.

For example, socket policies are handled such that if the security
layer gives an error we behave as if the socket policy did not match.

Whereas we handle sub vs. primary global policies differently.  If we
hit a sub-policy match, and we get a security layer error, we signal a
full lookup failure instead of trying to see if there is a primary
policy that the security layer likes.

I'm not saying either is wrong, I'm just pointing it out to make sure
this is intentional.

The socket policy behavior deserves some scrutiny.  I say this because
if a matching socket policy is avoided due to security layer error,
this could potentially make key manager problems very hard to
diagnose.
