From: Paul Moore <paul@paul-moore.com>
Subject: Re: Possible fix
Date: Fri, 07 Mar 2014 10:50:17 -0500
Message-ID: <1771362.YLy4DXk94D@sifl>
References: <20140227151954.GA30946@redhat.com> <7881571.eH1vgtYEXX@sifl> <20140307112334.GT32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>, Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-security-module@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:61016 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694AbaCGPuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 10:50:21 -0500
Received: by mail-qa0-f43.google.com with SMTP id j15so4163959qaq.16
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 07:50:20 -0800 (PST)
In-Reply-To: <20140307112334.GT32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, March 07, 2014 12:23:34 PM Steffen Klassert wrote:
> On Thu, Mar 06, 2014 at 10:04:54PM -0500, Paul Moore wrote:
> > On Wednesday, March 05, 2014 01:20:09 PM Steffen Klassert wrote:
> > > Right, that's not really surprising. But it is a bit surprising that
> > > we care for the security context only if we add a socket policy via
> > > the pfkey key manager. The security context is not handled if we do
> > > that with the netlink key manager, see xfrm_compile_policy().
> > > 
> > > I'm not that familiar with selinux and labeled IPsec, but maybe this
> > > needs to be implemented in xfrm_compile_policy() too.
> > 
> > Okay, I see your point.  We probably should add support for per-socket
> > policy labels just to keep parity with the pfkey code (and this is far
> > removed from any critical path), but to be honest it isn't something that
> > I think would get much use in practice.  Labeled networking users tend to
> > fall under the very strict, one-system-wide-security-policy and
> > per-socket policies tend to go against that logic.
> 
> If you think socket policy labels are no usecase for labeled IPsec, we could
> fix this bug simply by removing the code from pfkey ;)
> 
> Otherwise I think we should implement it for xfrm_compile_policy() too.

In general I dislike removing functionality/capability so I'm inclined to add 
support to xfrm_compile_policy and call it good.

-- 
paul moore
www.paul-moore.com
