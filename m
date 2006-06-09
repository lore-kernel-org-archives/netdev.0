From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] LSM-IPsec SELinux Authorize (with minor fix)
Date: Thu, 08 Jun 2006 23:53:32 -0700 (PDT)
Message-ID: <20060608.235332.41879542.davem@davemloft.net>
References: <Pine.LNX.4.64.0606060133220.9787@d.namei>
	<OF4F545512.79E4862D-ON85257185.005181A7-85257185.00520729@us.ibm.com>
	<20060608.234003.18579552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, chrisw@osdl.org,
	herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, latten@austin.ibm.com, sergeh@us.ibm.com,
	gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41163
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751385AbWFIGyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 02:54:17 -0400
To: cxzhang@us.ibm.com
In-Reply-To: <20060608.234003.18579552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 08 Jun 2006 23:40:03 -0700 (PDT)

> From: Xiaolan Zhang <cxzhang@us.ibm.com>
> Date: Tue, 6 Jun 2006 10:55:58 -0400
> 
> > Singned-off-by: Catherine Zhang <cxzhang@watson.ibm.com>
> > 
> > James, is this enough or do I need to modify the original patch to add the 
> > above line?  The code was taken from various pieces of patches originally 
> > from Trent and merged/modified by me.  Let me know what else I need to do.
> 
> That's good enough for me, patch applied, thanks a lot.

BTW, can I ask you SELINUX folks to at least attempt to do
a build with SELINUX disabled when you submit networking
changes to me?  It would save me a lot of time, this one
failed with:

net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_del_sa$,1ry(B:
net/xfrm/xfrm_user.c:430: warning: passing argument 1 of $,1rx(Bsecurity_xfrm_state_delete$,1ry(B from incompatible pointer type
net/xfrm/xfrm_user.c:430: warning: suggest parentheses around assignment used as truth value
net/xfrm/xfrm_user.c: In function $,1rx(Bxfrm_get_policy$,1ry(B:
net/xfrm/xfrm_user.c:1060: warning: suggest parentheses around assignment used as truth value

because the nop implementation of security_xfrm_state_delete()
was declared to take an xfrm_policy instead of an xfrm_state.

I've fixed all of this up, but please test this stuff out next
time around.  Thanks a lot.
