From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Mon, 02 Mar 2009 23:20:49 +0100
Message-ID: <49AC5BC1.3030901@trash.net>
References: <49A4D5D5.5090602@trash.net>	<20090225061902.GA32430@gondor.apana.org.au>	<49A4E3F8.4050406@trash.net>	<49A4F0D7.20304@trash.net>	<20090225084321.GA1101@gondor.apana.org.au>	<m163ixk9t2.fsf@fess.ebiederm.org>	<20090226062257.GA11511@gondor.apana.org.au>	<m14oyhis31.fsf@fess.ebiederm.org>	<20090226084924.16cb3e08@nehalam>	<49A83063.2060600@candelatech.com> <20090227103812.14af52b3@nehalam> <49AC597B.4090404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55725 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbZCBWUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 17:20:54 -0500
In-Reply-To: <49AC597B.4090404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> With both of Stephen's patches included in the latest -rc6 source,
> I re-ran the test and it seems to be working (I added printks so
> that I would know the new code was being exercise
> 
> I had 2000 or so mac-vlans configured, with 10 of them being
> re-configured concurrently, while also deleting groups of 20-100
> mac-vlans in my test.  This was locking up reliably before,
> and now it seems to be working fine.
> 
> Here's the kernel log showing the ERESTARTSYS in action.  I don't
> have an easy way to check to see if the VFS (or whatever) retried
> the call properly, but will let you all know if I see any indication
> that isn't working.
> 
> I only saw the ipv6 fixup in my logs, but maybe my test case just
> doesn't hit the other...

This looks like its working fine. Despite the non-desirable active
spinning, this seems like the best fix (actually much simpler than
I expected to be possible) at this time. If we just could avoid
the spinning when unnecessary, it would be perfect :)
