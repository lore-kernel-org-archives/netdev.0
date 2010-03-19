From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netlink: convert DIY reader/writer to mutex and RCU
 (v2)
Date: Thu, 18 Mar 2010 17:44:59 -0700
Message-ID: <20100318174459.207f4969@nehalam>
References: <20100308133211.4f157e2d@nehalam>
	<20100308140021.234a120a@nehalam>
	<1268751635.3094.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49745 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163Ab0CSApG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 20:45:06 -0400
In-Reply-To: <1268751635.3094.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Mar 2010 16:00:35 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 08 mars 2010 =C3=A0 14:00 -0800, Stephen Hemminger a =C3=A9c=
rit :
> > The netlink table locking was open coded version of reader/writer
> > sleeping lock.  Change to using mutex and RCU which makes
> > code clearer, shorter, and simpler.
> >=20
> > Could use sk_list nulls but then would have to have kmem_cache
> > for netlink handles and that seems like unnecessary bloat.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > ---

Maybe using rcu list_nulls would be better.
The problem is what about the bind_node hash list.
