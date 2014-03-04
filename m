From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: out of bounds writes in net/hsr/
Date: Tue, 4 Mar 2014 17:07:23 +0100
Message-ID: <5315FA3B.8020700@alten.se>
References: <20140304032757.GA19048@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:61529 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696AbaCDQQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 11:16:09 -0500
In-Reply-To: <20140304032757.GA19048@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-03-04 04:27, Dave Jones wrote:
> I found this in coverity, and I think it's a real bug..
>=20
> hsr_register_frame_in does a check that dev_idx is between 0 and 2,
> therefore, a dev_idx of 2 is possible when it gets to the array write=
s
> at the end of the function.=20

Thanks for finding this; it is a bug (although I don't think it has=20
actually lead to any out of bound accesses).=20

However, I think you are a bit late - I believe this was fixed in a pat=
ch=20
from Dan Carpenter just a few days ago. See

http://www.spinics.net/lists/netdev/msg272815.html


> #define HSR_MAX_DEV     (HSR_DEV_MASTER + 1)
>=20
> The + 1 seems odd, and looking at the other uses of HSR_MAX_DEV, I ca=
n't
> figure out why it's there.
>=20
> 	Dave
>=20

Yes, maybe the names are a bit misleading, and they should be called so=
mething=20
like HSR_DEVS and HSR_SLAVES instead. I.e.:

	some-type array-name[HSR_DEVS];

=2E.. where the last element is accessed by array-name[HSR_MAX_DEV].



--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
