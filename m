From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: double SAs are created when using AH and ESP together
Date: Fri, 09 Mar 2007 16:20:27 -0800 (PST)
Message-ID: <20070309.162027.38709797.davem@davemloft.net>
References: <200703092314.l29NEsre023870@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eparis@redhat.com,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767680AbXCJAU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 19:20:28 -0500
In-Reply-To: <200703092314.l29NEsre023870@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Fri, 9 Mar 2007 17:14:54 -0600

> I noticed that in xfrm_state_add we look for the larval SA in a few
> places without checking for protocol match. So when using both 
> AH and ESP, whichever one gets added first, deletes the larval SA. 
> It seems AH always gets added first and ESP is always the larval 
> SA's protocol since the xfrm->tmpl has it first. Thus causing the
> additional km_query()
> 
> Adding the check eliminates the double SA creation. 
> I know this may not seem like a complete solution and I will 
> continue to test and be on the lookout, but isn't having the
> check a good thing? So far I have tested SAs with just ESP, just AH
> and with both and all seems ok. 
> 
> Please let me know if this patch is ok. 
> My kernel was 2.6.20-rc3-git3.
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

Generally it looks OK, but I'm going to let this one sit for
a while before I apply it so that other folks can review it
too and spot any unintended consequences.

In particular, I find it strance that we didn't check the
protocol field all this time and I wonder whether that might
be on purpose for some reason.
