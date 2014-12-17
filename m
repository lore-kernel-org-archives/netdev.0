From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 2/2] geneve: Fix races between socket add and release.
Date: Wed, 17 Dec 2014 21:15:13 +0000
Message-ID: <20141217211513.GF28766@casper.infradead.org>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
 <1418783132-99230-2-git-send-email-jesse@nicira.com>
 <20141217165454.GE28766@casper.infradead.org>
 <CAEP_g=_-hgeosH83FdPZLb9mvi5DSW6mbe+Xe5x0YoR7mKaTPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57855 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbaLQVPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 16:15:17 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=_-hgeosH83FdPZLb9mvi5DSW6mbe+Xe5x0YoR7mKaTPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/14 at 10:48am, Jesse Gross wrote:
> I generally agree (with the exception of kfree_rcu() - I believe that
> is still needed since incoming packets reference it using RCU).

I didn't inspect this in full detail but seems like the data path
should only care about gs->sock which is properly refcnt'ed.

> However, since this patch is targeted a net- I wanted to make a
> minimal change and not completely redo the locking. A lot of the
> locking here was pulled over from VXLAN and I think it can be
> simplified since I don't expect that the Geneve code will bring in all
> of that logic.

Makes sense. Feel free to take:
Acked-by: Thomas Graf <tgraf@suug.ch>

> for destroying the socket. This was added by Stephen in "vxlan: listen
> on multiple ports" but it's not obvious to me what problem it is
> trying to avoid and I don't see a comment. If possible, it would be
> nice to simplify this as well if the issue doesn't apply to Geneve.

I don't have an explanation for that either. Each entry on the
vni_list[] takes a vs->refcnt.
