From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit to upper layer
Date: Wed, 11 Mar 2009 12:13:58 +0100
Message-ID: <877i2wfh1l.fsf@basil.nowhere.org>
References: <1236761624.2567.442.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36032 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978AbZCKLQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 07:16:19 -0400
In-Reply-To: <1236761624.2567.442.camel@ymzhang> (Yanmin Zhang's message of "Wed, 11 Mar 2009 16:53:44 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Zhang, Yanmin" <yanmin_zhang@linux.intel.com> writes:

> I got some comments. Special thanks to =EF=BB=BFStephen Hemminger for=
 teaching me on
> what reorder is and some other comments. Also thank other guys who ra=
ised comments.


>
> v2 has some improvements.
> 1) Add new sysfs interface /sys/class/net/ethXXX/rx_queueXXX/processi=
ng_cpu. Admin
> could use it to configure the binding between RX and cpu number. So i=
t's convenient
> for drivers to use the new capability.

Seems very inconvenient to have to configure this by hand. How about
auto selecting one that shares the same LLC or somesuch? Passing
data to anything with the same LLC should be cheap enough.

BTW the standard idea to balance processing over multiple CPUs was to
use MSI-X to multiple CPUs. and just use the hash function on the
NIC. Have you considered this for forwarding too? The trick here would
be to try to avoid reordering inside streams as far as possible, but
since the NIC hash should work on flow basis that should be ok.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
