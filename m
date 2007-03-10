From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: double SAs are created when using AH and ESP together
Date: Fri, 09 Mar 2007 18:55:36 -0600
Message-ID: <1173488136.3085.104.camel@faith.austin.ibm.com>
References: <200703092314.l29NEsre023870@faith.austin.ibm.com>
	 <20070309.162027.38709797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eparis@redhat.com,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:55138 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767705AbXCJBLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 20:11:38 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2A1BcED007287
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 20:11:38 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2A1BbEi551134
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 18:11:37 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2A1Ba83019112
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 18:11:37 -0700
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

Ok. And I'll continue to test, though most of my testing is
done on lspp kernel. 

lspp kernel is an earlier version of upstream kernel and
I noticed the old __xfrm4_find_acq() did include a check for the
protocol, new __find_acq_core() doesn't.
But neither checked for protocol after call to __xfrm_find_acq_byseq(). 

Joy

