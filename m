From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 2/2] selinux: add gfp argument to
 security_xfrm_policy_alloc and fix callers
Date: Mon, 10 Mar 2014 13:52:03 +0100
Message-ID: <20140310125203.GZ32371@secunet.com>
References: <20140227151954.GA30946@redhat.com>
 <1394192659-10764-1-git-send-email-nikolay@redhat.com>
 <1394192659-10764-3-git-send-email-nikolay@redhat.com>
 <2297449.8Lk5u4VomY@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, <netdev@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	LSM list <linux-security-module@vger.kernel.org>,
	SELinux list <selinux@tycho.nsa.gov>
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2297449.8Lk5u4VomY@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 07, 2014 at 05:27:17PM -0500, Paul Moore wrote:
> On Friday, March 07, 2014 12:44:19 PM Nikolay Aleksandrov wrote:
> > security_xfrm_policy_alloc can be called in atomic context so the
> > allocation should be done with GFP_ATOMIC. Add an argument to let the
> > callers choose the appropriate way. In order to do so a gfp argument
> > needs to be added to the method xfrm_policy_alloc_security in struct
> > security_operations and to the internal function
> > selinux_xfrm_alloc_user. After that switch to GFP_ATOMIC in the atomic
> > callers and leave GFP_KERNEL as before for the rest.
> > The path that needed the gfp argument addition is:
> > security_xfrm_policy_alloc -> security_ops.xfrm_policy_alloc_security ->
> > all users of xfrm_policy_alloc_security (e.g. selinux_xfrm_policy_alloc) ->
> > selinux_xfrm_alloc_user (here the allocation used to be GFP_KERNEL only)
> > 
> > Now adding a gfp argument to selinux_xfrm_alloc_user requires us to also
> > add it to security_context_to_sid which is used inside and prior to this
> > patch did only GFP_KERNEL allocation. So add gfp argument to
> > security_context_to_sid and adjust all of its callers as well.
> > 
> > CC: Paul Moore <paul@paul-moore.com>
> > CC: Dave Jones <davej@redhat.com>
> > CC: Steffen Klassert <steffen.klassert@secunet.com>
> > CC: Fan Du <fan.du@windriver.com>
> > CC: David S. Miller <davem@davemloft.net>
> > CC: LSM list <linux-security-module@vger.kernel.org>
> > CC: SELinux list <selinux@tycho.nsa.gov>
> > 
> > Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> This looks good to me, thanks for finding this and following through with a 
> patch.
> 
> Acked-by: Paul Moore <paul@paul-moore.com>
> 

Both patches applied to the ipsec tree.

Thanks everyone!
