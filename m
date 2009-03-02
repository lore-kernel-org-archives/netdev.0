From: David Miller <davem@davemloft.net>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Mon, 02 Mar 2009 14:47:25 -0800 (PST)
Message-ID: <20090302.144725.223672439.davem@davemloft.net>
References: <20090227103812.14af52b3@nehalam>
	<49AC597B.4090404@candelatech.com>
	<49AC5BC1.3030901@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, shemminger@vyatta.com,
	ebiederm@xmission.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57671
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751767AbZCBWro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 17:47:44 -0500
In-Reply-To: <49AC5BC1.3030901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 02 Mar 2009 23:20:49 +0100

> Ben Greear wrote:
> > With both of Stephen's patches included in the latest -rc6 source,
> > I re-ran the test and it seems to be working (I added printks so
> > that I would know the new code was being exercise
> > I had 2000 or so mac-vlans configured, with 10 of them being
> > re-configured concurrently, while also deleting groups of 20-100
> > mac-vlans in my test.  This was locking up reliably before,
> > and now it seems to be working fine.
> > Here's the kernel log showing the ERESTARTSYS in action.  I don't
> > have an easy way to check to see if the VFS (or whatever) retried
> > the call properly, but will let you all know if I see any indication
> > that isn't working.
> > I only saw the ipv6 fixup in my logs, but maybe my test case just
> > doesn't hit the other...
> 
> This looks like its working fine. Despite the non-desirable active
> spinning, this seems like the best fix (actually much simpler than
> I expected to be possible) at this time. If we just could avoid
> the spinning when unnecessary, it would be perfect :)

Could you give that "not actually in-progress" detection a shot?

I don't like the spinning either.
