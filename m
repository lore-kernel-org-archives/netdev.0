From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Possible fix
Date: Fri, 7 Mar 2014 12:23:34 +0100
Message-ID: <20140307112334.GT32371@secunet.com>
References: <20140227151954.GA30946@redhat.com>
 <8608950.OLpq4oFFJB@sifl>
 <20140305122009.GR32371@secunet.com>
 <7881571.eH1vgtYEXX@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, <netdev@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-security-module@vger.kernel.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7881571.eH1vgtYEXX@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 06, 2014 at 10:04:54PM -0500, Paul Moore wrote:
> On Wednesday, March 05, 2014 01:20:09 PM Steffen Klassert wrote:
> >
> > Right, that's not really surprising. But it is a bit surprising that
> > we care for the security context only if we add a socket policy via
> > the pfkey key manager. The security context is not handled if we do
> > that with the netlink key manager, see xfrm_compile_policy().
> > 
> > I'm not that familiar with selinux and labeled IPsec, but maybe this
> > needs to be implemented in xfrm_compile_policy() too.
> 
> Okay, I see your point.  We probably should add support for per-socket policy 
> labels just to keep parity with the pfkey code (and this is far removed from 
> any critical path), but to be honest it isn't something that I think would get 
> much use in practice.  Labeled networking users tend to fall under the very 
> strict, one-system-wide-security-policy and per-socket policies tend to go 
> against that logic.
> 

If you think socket policy labels are no usecase for labeled IPsec, we could
fix this bug simply by removing the code from pfkey ;)

Otherwise I think we should implement it for xfrm_compile_policy() too.
