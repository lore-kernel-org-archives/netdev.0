From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH]: double SAs are created when using AH and ESP together
Date: Fri, 09 Mar 2007 19:54:15 -0500
Message-ID: <1173488055.16821.50.camel@localhost.localdomain>
References: <200703092314.l29NEsre023870@faith.austin.ibm.com>
	 <20070309.162027.38709797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768AbXCJAyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 19:54:45 -0500
In-Reply-To: <20070309.162027.38709797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-09 at 16:20 -0800, David Miller wrote:
> From: Joy Latten <latten@austin.ibm.com>
> Date: Fri, 9 Mar 2007 17:14:54 -0600
> 
> > I noticed that in xfrm_state_add we look for the larval SA in a few
> > places without checking for protocol match. So when using both 
> > AH and ESP, whichever one gets added first, deletes the larval SA. 
> > It seems AH always gets added first and ESP is always the larval 
> > SA's protocol since the xfrm->tmpl has it first. Thus causing the
> > additional km_query()
> > 
> > Adding the check eliminates the double SA creation. 
> > I know this may not seem like a complete solution and I will 
> > continue to test and be on the lookout, but isn't having the
> > check a good thing? So far I have tested SAs with just ESP, just AH
> > and with both and all seems ok. 
> > 
> > Please let me know if this patch is ok. 
> > My kernel was 2.6.20-rc3-git3.
> > 
> > Signed-off-by: Joy Latten <latten@austin.ibm.com>
> 
> Generally it looks OK, but I'm going to let this one sit for
> a while before I apply it so that other folks can review it
> too and spot any unintended consequences.
> 
> In particular, I find it strance that we didn't check the
> protocol field all this time and I wonder whether that might
> be on purpose for some reason.

At least the first hunk of this patch used to be checked back in
net/ipv4/xfrm4_state.c in __xfrm4_find_acq and looks like it just was
accidentally forgotten when there was a transition to using
__find_acq_core

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=2770834c9f44afd1bfa13914c7285470775af657

Since Joy found this problem on a 2.6.18 kernel originally which was
before this diff and had the proto check I'm guessing it is actually the
second hunk which is more relevant to the problem.

-Eric

