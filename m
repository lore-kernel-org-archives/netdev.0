From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Generalizing mmap'ed sockets
Date: Wed, 24 Nov 2010 21:57:37 +0200
Message-ID: <20101124195737.GB31861@redhat.com>
References: <4CE6ED09.70602@hp.com>
 <20101119.135213.15239226.davem@davemloft.net>
 <4CE6F2FD.8080301@hp.com>
 <20101119.140818.242132853.davem@davemloft.net>
 <AANLkTik7HU0wyub3krZb_aABsHp-_LvNLtAr5CaAo4_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38781 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932079Ab0KXT6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 14:58:54 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTik7HU0wyub3krZb_aABsHp-_LvNLtAr5CaAo4_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 02:49:46PM -0800, Tom Herbert wrote:
> > I think the ACK (or for UDP, the kfree_skb() after TX completes) sh=
ould
> > move the consumer pointer. =A0Otherwise you have to copy, and the A=
CKs
> > do not clock the sender process properly.
> >
> Right, with the caveats that even ACK'ed data might still go out on
> the with that was discussed in the vmsplice() related patches.  I
> don't think this should make the problem any worse.

Or any better. Sigh. Any idea how to actually track pages
in question so we can either really know when the stack is no longer
referencing them, or force a copy if they hang around after ack?

--=20
MST
