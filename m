From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Thu, 07 Dec 2006 14:03:13 -0800 (PST)
Message-ID: <20061207.140313.71569226.davem@davemloft.net>
References: <20061206.233749.122048397.davem@davemloft.net>
	<20061206.234857.70203259.davem@davemloft.net>
	<4577F9C4.2020301@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60947
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1163433AbWLGWDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 17:03:01 -0500
To: kazunori@miyazawa.org
In-Reply-To: <4577F9C4.2020301@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Thu, 07 Dec 2006 20:23:48 +0900

> David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Wed, 06 Dec 2006 23:37:49 -0800 (PST)
> > 
> >> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> >> Date: Wed, 6 Dec 2006 20:35:37 +0900
> >>
> >>> BTW, I have a question about descrementing the reference count of
> >>> rt->peer.  The reference cound in normal "dst" structure is
> >>> decremented by calling inet_putpeer from ipv4_dst_destroy. But
> >>> xfrm4_dst_destroy does not call inet_putpeer.  Where do we decrement
> >>> the count? Should xfrm4_dst_destroy do that?
> >> Indeed, it is a real leak.  And yes, I believe that xfrm4_dst_destroy()
> >> should release it.  I will make this fix, thank you.
> > 
> > For reference, this is the fix I checked in.
> > 
> > Thanks again for spotting this problem.
> 
> Thank you for making the patch.
> Will it be merged to 2.6.19.x?

Yes, I submitted it to -stable last night and Chris W. just
queued it up for the -stable branches (even 2.6.18.x etc.)
