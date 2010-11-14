From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] nete zero kobject in rx_queue_release
Date: Sun, 14 Nov 2010 15:15:29 -0800 (PST)
Message-ID: <20101114.151529.183053743.davem@davemloft.net>
References: <20101111201341.4418.16400.stgit@jf-dev1-dcblab>
	<20101112.130824.68146775.davem@davemloft.net>
	<AANLkTi=1Xzne6HZN-w_3RTeUmqtjGpHPfW211SKvW17w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44844
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754707Ab0KNXPH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Nov 2010 18:15:07 -0500
In-Reply-To: <AANLkTi=1Xzne6HZN-w_3RTeUmqtjGpHPfW211SKvW17w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom Herbert <therbert@google.com>
Date: Sun, 14 Nov 2010 14:40:00 -0800

>> So we'll need something like:
>>
>> =A0 =A0 =A0 =A0if (atomic_dec_and_test(&first->count))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(first);
>> =A0 =A0 =A0 =A0else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* clear everything except queue->fir=
st */
>>
>=20
> The patches to get rid of the separate refcnt should obviate this
> complexity.  Could just clear the queue in kobject release.

True but we'll still need a patch for older kernels.
