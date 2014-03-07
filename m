From: Paul Moore <paul@paul-moore.com>
Subject: Re: Possible fix
Date: Thu, 06 Mar 2014 22:04:54 -0500
Message-ID: <7881571.eH1vgtYEXX@sifl>
References: <20140227151954.GA30946@redhat.com> <8608950.OLpq4oFFJB@sifl> <20140305122009.GR32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>, Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-security-module@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:54032 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbaCGDE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 22:04:58 -0500
Received: by mail-qc0-f180.google.com with SMTP id x3so4010654qcv.25
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 19:04:57 -0800 (PST)
In-Reply-To: <20140305122009.GR32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, March 05, 2014 01:20:09 PM Steffen Klassert wrote:
> On Fri, Feb 28, 2014 at 05:10:47PM -0500, Paul Moore wrote:
> > On Friday, February 28, 2014 11:10:07 AM Nikolay Aleksandrov wrote:
> > > On 02/28/2014 08:23 AM, Steffen Klassert wrote:
> > > > Looking at the git history, it seems that this bug is about nine
> > > > years old. I guess noone is actually using this.
> > 
> > Most (all?) of the labeled IPsec users use the netlink interface and not
> > pfkey so it isn't surprising that this has gone unnoticed for some time.
>
> Right, that's not really surprising. But it is a bit surprising that
> we care for the security context only if we add a socket policy via
> the pfkey key manager. The security context is not handled if we do
> that with the netlink key manager, see xfrm_compile_policy().
> 
> I'm not that familiar with selinux and labeled IPsec, but maybe this
> needs to be implemented in xfrm_compile_policy() too.

Okay, I see your point.  We probably should add support for per-socket policy 
labels just to keep parity with the pfkey code (and this is far removed from 
any critical path), but to be honest it isn't something that I think would get 
much use in practice.  Labeled networking users tend to fall under the very 
strict, one-system-wide-security-policy and per-socket policies tend to go 
against that logic.

I'll have to think about it some more.

-- 
paul moore
www.paul-moore.com
