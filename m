From: Helge Deller <deller@gmx.de>
Subject: Re: CONFIG_XPS depends on L1_CACHE_BYTES being greater than
 sizeof(struct xps_map)
Date: Fri, 23 Oct 2015 21:25:04 +0200
Message-ID: <562A8990.9000808@gmx.de>
References: <42430464-867C-4E0B-8E95-C6CDB6D8A0B2@bell.net>
 <32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
 <B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
 <trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
 <trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
 <1445524549.2207.1.camel@HansenPartnership.com> <5628F868.3040105@bell.net>
 <5629404B.8090805@gmx.de>
 <1445550615.22974.128.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	John David Anglin <dave.anglin@bell.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:49418 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327AbbJWTZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 15:25:16 -0400
In-Reply-To: <1445550615.22974.128.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.10.2015 23:50, Eric Dumazet wrote:
> On Thu, 2015-10-22 at 22:00 +0200, Helge Deller wrote:
>> Hi Tom & David,
>>
>> I've queued-up a patch for the parisc architecture which reduces L1_=
CACHE_BYTES from 32 to 16:
>>   https://patchwork.kernel.org/patch/7399291/
>>
>> But this change will break the kernel build like this:
>>
>> In file included from net/core/dev.c:92:0:
>> net/core/dev.c: In function =E2=80=98expand_xps_map=E2=80=99:
>> include/linux/netdevice.h:721:27: warning: overflow in implicit cons=
tant conversion [-Woverflow]
>>    #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_ma=
p)) \
>> net/core/dev.c:1972:18: note: in expansion of macro =E2=80=98XPS_MIN=
_MAP_ALLOC=E2=80=99
>>    int alloc_len =3D XPS_MIN_MAP_ALLOC;
>>
>> Do you see an easy way to fix this ?
>=20
>=20
> Using L2_CACHE_BYTES would be better, but it unfortunately does not
> exist.

Then, how about simply changing it to twice of L1_CACHE_BYTES ?

#define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES * 2 - sizeof(struct xps_map)=
) / sizeof(u16))

Helge
