From: "John Stoffel" <john@stoffel.org>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 16:40:41 -0400
Message-ID: <20866.53065.328731.479441@quad.stoffel.home>
References: <20130502.041625.412316202038784117.davem@davemloft.net>
	<20130502083619.GA22010@macbook.localnet>
	<87d2t9bvj1.fsf@nemi.mork.no>
	<20130502.140125.697030413654996310.davem@davemloft.net>
	<20866.46636.642215.768865@quad.stoffel.home>
	<1367525887.5106.140.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Stoffel <john@stoffel.org>,
	David Miller <davem@davemloft.net>, <bjorn@mork.no>,
	<kaber@trash.net>, <torvalds@linux-foundation.org>,
	<hayeswang@realtek.com>, <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367525887.5106.140.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Ben" =3D=3D Ben Hutchings <bhutchings@solarflare.com> writes:

Ben> On Thu, 2013-05-02 at 14:53 -0400, John Stoffel wrote:
>> >>>>> "David" =3D=3D David Miller <davem@davemloft.net> writes:
>>=20
David> From: Bj=F8rn Mork <bjorn@mork.no>
David> Date: Thu, 02 May 2013 11:06:42 +0200
>>=20
>> >> From d957cf339bf625869c39d852ac6733ef597ecef9 Mon Sep 17 00:00:00=
 2001
>> >> From: Bj=F8rn Mork <bjorn@mork.no>
>> >> Date: Thu, 2 May 2013 10:37:05 +0200
>> >> Subject: [PATCH] net: vlan,ethtool: netdev_features_t is more tha=
n 32 bit
>> >> MIME-Version: 1.0
>> >> Content-Type: text/plain; charset=3DUTF-8
>> >> Content-Transfer-Encoding: 8bit
>> >>=20
>> >> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
>>=20
David> Also applied and queued up for -stable.
>>=20
David> These changes show me that this special type isn't providing typ=
e
David> safety in the way that we actually need it.
>>=20
David> Something like how we do the MM page table types would work bett=
er:
>>=20
David> typedef struct { u64 val; } netdev_features_t;
>>=20
David> #define __netdev_feature(X)	((netdev_features_t) { X } )
>>=20
David> and also with the appropriate set of accessors.
>>=20
David> Then you can't get it wrong without a compile error.
>>=20
>> Isn't part of the problem that you're exporting it into /sys in a
>> binary format?
Ben> [...]

Ben> Features are exported through SIOCETHTOOL, not sysfs (though they =
*used*
Ben> to be there).

Ben> The 'flags' attribue in sysfs is something different.

THanks for the clarification.
